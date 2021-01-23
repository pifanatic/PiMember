import PIML from "./piml.min.js";

let front = document.getElementById("front-text"),
    back  = document.getElementById("back-text");

front.innerHTML = PIML.parse(front.innerText.trim());
back.innerHTML  = PIML.parse(back.innerText.trim());
