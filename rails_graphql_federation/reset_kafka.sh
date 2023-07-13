#!/bin/sh

readonly KAFKA_SERVICE=kafka
readonly KAFKA_PATH=/opt/bitnami/kafka/bin

# Erase all topics and messages currently in Kafka

echo "Remove existing Kafka broker, if any, and their data"
docker compose down --volumes
echo ""

echo "Launch new Kafka broker"
docker compose up -d
echo ""

echo "Waiting for broker to become available"
sleep 3

# Re-create topics
for topic in book-reviews.{books,reviews,users,searches}
do
  echo "Create topic" $topic
  docker compose exec $KAFKA_SERVICE \
    $KAFKA_PATH/kafka-topics.sh \
    --bootstrap-server ${KAFKA_SERVICE}:9092 \
    --create \
    --topic $topic
  echo ""
done

echo "Done"
