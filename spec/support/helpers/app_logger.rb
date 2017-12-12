require "kafka"

class AppLogger
  attr_accessor :offset


  def offset=(v)
    v=0 if v<0

    @offset = v

    @offset
  end

  def offset
    @offset ||= 0

    @offset
  end

  def get_kafka
    if @kafka.nil?
      @kafka = Kafka.new(
          seed_brokers: ["#{Myconfig.config[:kafka_server]}:#{Myconfig.config[:kafka_port]}"],
      )
    end

    @kafka
  end

  def get_kafka_consumer
    if @kafka_consumer.nil?
      kafka = get_kafka
      @kafka_consumer = kafka.consumer(group_id: "my-consumer")
    end

    @kafka_consumer
  end

  # skip offset for kafka
  def log_skip_all
    kafka = get_kafka
    kafka_topic = Myconfig.config[:kafka_topic]


    #kafka.fetch_messages(topic: kafka_topic, partition: 0, offset: offset).each do |message|
    kafka.fetch_messages(topic: kafka_topic, partition: 0, offset: :latest).each do |message|
      # change offset
      $logger.offset = message.offset

      break
    end

    puts "kafka: skipped to offset #{offset}"
  end
end
