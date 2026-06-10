const express = require("express");
const app = express();

app.set("view engine", "ejs");

app.get("/", (req, res) => {
  res.render("index", {
    serverName: "Mon Serveur Minecraft",
    ip: "YOUR_VPS_IP:12000",
    description: "Serveur Minecraft Paper avec plugins et monitoring.",
  });
});

app.listen(3000, () => {
  console.log("Landing page running on port 3000");
});