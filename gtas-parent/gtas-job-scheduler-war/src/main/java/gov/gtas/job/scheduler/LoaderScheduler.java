/*
 * All GTAS code is Copyright 2016, The Department of Homeland Security (DHS), U.S. Customs and Border Protection (CBP).
 * 
 * Please see LICENSE.txt for details.
 */
package gov.gtas.job.scheduler;

/*
 * All GTAS code is Copyright 2016, The Department of Homeland Security (DHS), U.S. Customs and Border Protection (CBP).
 * 
 * Please see LICENSE.txt for details.
 */
import static gov.gtas.constant.GtasSecurityConstants.GTAS_APPLICATION_USERID;

import gov.gtas.enumtype.AuditActionType;
import gov.gtas.json.AuditActionData;
import gov.gtas.json.AuditActionTarget;
import gov.gtas.model.MessageStatus;
import gov.gtas.parsers.tamr.jms.TamrMessageSender;
import gov.gtas.parsers.tamr.model.TamrMessageType;
import gov.gtas.parsers.tamr.model.TamrPassenger;
import gov.gtas.parsers.tamr.model.TamrQuery;
import gov.gtas.parsers.omni.jms.OmniMessageSender;
import gov.gtas.parsers.omni.model.OmniMessageType;
import gov.gtas.parsers.omni.model.OmniPassenger;
import gov.gtas.repository.MessageStatusRepository;
import gov.gtas.services.*;
import gov.gtas.services.matcher.MatchingService;
import gov.gtas.summary.MessageAction;
import gov.gtas.summary.MessageSummaryList;
import gov.gtas.services.jms.AdditionalProcessingMessageSender;
import gov.gtas.summary.SummaryMetaData;
import gov.gtas.svc.TargetingService;


import java.io.File;
import java.util.Date;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Message Loader Scheduler class. Using Spring's Scheduled annotation for
 * scheduling tasks. The class reads configuration values from an external file.
 *
 */
@Component
public class LoaderScheduler {

	private static final Logger logger = LoggerFactory.getLogger(LoaderScheduler.class);

	/**
	 * The Enum InputType.
	 */
	public enum InputType {
		TWO_DIRS("two_dirs");
		private final String stringValue;

		private InputType(final String s) {
			stringValue = s;
		}

		@Override
		public String toString() {
			return stringValue;
		}
	}

	@Autowired
	private TargetingService targetingService;

	@Autowired
	private Loader loader;

	@Autowired
	private ErrorPersistenceService errorPersistenceService;

	@Autowired
	private AuditLogPersistenceService auditLogPersistenceService;

	@Autowired
	private MatchingService matchingService;

	@Autowired
	private MessageStatusRepository messageStatusRepository;

	@Autowired(required=false)
	private TamrMessageSender tamrMessageSender;

	@Autowired(required=false)
	private OmniMessageSender omniMessageSender;

	@Value("${message.dir.processed}")
	private String messageProcessedDir;

	@Value("${message.dir.working}")
	private String messageWorkingDir;

	@Value("${message.dir.error}")
	private String messageErrorDir;

	@Value("${inputType}")
	private String inputType;

	@Value("${maxNumofFiles}")
	private int maxNumofFiles;

	@Value("${tamr.enabled}")
	private Boolean tamrEnabled;

	@Value("${omni.enabled}")
	private Boolean omniEnabled;

	@Value("${additional.processing.enabled.passenger}")
	private Boolean additionalChecks;

	@Autowired
	private AdditionalProcessingMessageSender apms;

	@Value("${additional.checks.queue}")
	private String addChecks;

	void processSingleFile(File f, LoaderStatistics stats, String[] primeFlightKey) {
		logger.debug(String.format("Processing %s", f.getAbsolutePath()));
		ProcessedMessages processedMessages = loader.processMessage(f, primeFlightKey);
		int[] result = processedMessages.getProcessed();
		List<MessageStatus> messageStatusList = processedMessages.getMessageStatusList();
		messageStatusRepository.saveAll(messageStatusList);

		if (tamrEnabled) {
			List<TamrPassenger> passToSend = processedMessages.getTamrPassengers();
			TamrQuery tamrQuery = new TamrQuery(passToSend);
			tamrMessageSender.sendMessageToTamr(
			        TamrMessageType.QUERY, tamrQuery);
		}

		if (omniEnabled) {
			List<OmniPassenger> passengerList = processedMessages.getOmniPassengers();
			omniMessageSender.sendMessageToOmni(
					OmniMessageType.ASSESS_RISK_REQUEST, passengerList);
		}

		if (additionalChecks) {
			MessageSummaryList msl = MessageSummaryList.from(processedMessages.getMessageSummaries());
			msl.setMessageAction(MessageAction.PROCESSED_MESSAGE);
			apms.sendProcessedMessage(addChecks, msl, new SummaryMetaData());
		}

		if (result != null) {
			stats.incrementNumFilesProcessed();
			stats.incrementNumMessagesProcessed(result[0]);
			stats.incrementNumMessagesFailed(result[1]);
		} else {
			stats.incrementNumFilesAborted();
		}
	}

	// Method to be processed in thread generated by JMS listener
	public void receiveMessage(String text, String fileName, String[] primeFlightKey) throws Exception {
		LoaderStatistics stats = new LoaderStatistics();
		logger.debug("MESSAGE RECEIVED FROM QUEUE: " + messageWorkingDir + File.separator + fileName);

		File f = new File(messageWorkingDir + File.separator + fileName);
		processSingleFile(f, stats, primeFlightKey);
		saveProcessedFile(f);
		
	}

	// Moves the file from the working dir to the processed, returns true on
	// success.
	public boolean saveProcessedFile(File file) {
		boolean saved = false;

		if (file == null || !file.isFile())
			return saved;

		String destinationDir = messageProcessedDir;
		try {	
			Utils.moveToDirectory(destinationDir, file);	
		} catch (Exception ex) {	
			logger.error("Unable to move file '" + file.getName() + "' to directory: " + destinationDir, ex);	
		}
		
		return saved;
	}

	/**
	 * Writes the audit log with run statistics.
	 * 
	 * @param stats
	 *            the statistics bean.
	 */
	private void writeAuditLog(LoaderStatistics stats) {
		AuditActionTarget target = new AuditActionTarget(AuditActionType.LOADER_RUN, "GTAS Message Loader", null);
		AuditActionData actionData = new AuditActionData();
		actionData.addProperty("totalFilesProcessed", String.valueOf(stats.getNumFilesProcessed()));
		actionData.addProperty("totalFilesAborted", String.valueOf(stats.getNumFilesAborted()));
		actionData.addProperty("totalMessagesProcessed", String.valueOf(stats.getNumMessagesProcessed()));
		actionData.addProperty("totalMessagesInError", String.valueOf(stats.getNumMessagesFailed()));

		String message = "Message Loader run on " + new Date();
		auditLogPersistenceService.create(AuditActionType.LOADER_RUN, target, actionData, message,
				GTAS_APPLICATION_USERID);
	}
}
