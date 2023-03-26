const express = require("express");
const app = express();

setInterval(() => {
  console.log("PID", process.pid);
}, 1000);

app.get("/", (_, res) => {
  res.send("Hello world!");
});

const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
