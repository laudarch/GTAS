FROM adoptopenjdk/maven-openjdk8


COPY ./gtas-parent/ /gtas-parent
WORKDIR /gtas-parent
RUN mvn clean install --projects gtas-rule-runner -am

WORKDIR /gtas-parent/gtas-rule-runner
ENV RUN_ARGUMENTS ' --kb.list=${KB_LIST} \
                    --inbound.queue=${INBOUND_QUEUE} \
                    --outbound.queue=${OUTBOUND_QUEUE} \
                    --spring.datasource.url=${MAIRA_URL} \
                    --spring.datasource.username=${MARIA_USERNAME} \
                    --spring.datasource.password=${MARIA_PASSWORD} \
                    --spring.activemq.broker-url=tcp://${ACTIVE_MQ_HOST}'


CMD mvn spring-boot:run -Dspring-boot.run.arguments="$RUN_ARGUMENTS" -Dspring-boot.run.jvmArguments="$JVM_ARGS"