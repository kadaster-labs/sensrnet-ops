var kafka = require("kafka-node"),
    Producer = kafka.Producer,
    client = new kafka.KafkaClient(),
    producer = new Producer(client);

let count = 0;

producer.on("ready", function() {
    console.log("ready");
    setInterval(function() {
        payloads = [
            { topic: "sync", key:count, messages: `I have ${count} cats`, partition: 0 }
        ];
        console.log(payloads);

        producer.send(payloads, function(err, data) {
            console.log(err);
            console.log(data);
            count += 1;
        });
    }, 1000);
});

producer.on("error", function(err) {
    console.log(err);
});
