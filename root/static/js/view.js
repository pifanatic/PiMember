import PIML from "./piml-v030.min.js";

let front = document.getElementById("front-text"),
    back  = document.getElementById("back-text");

front.innerHTML = PIML.parse(front.textContent.trim());
back.innerHTML  = PIML.parse(back.textContent.trim());
