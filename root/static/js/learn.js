import PIML from "./piml.min.js";

let turnButton = document.getElementById("turn"),
    correctBtn = document.getElementById("answerCorrect"),
    wrongBtn   = document.getElementById("answerWrong"),
    cardEl     = document.getElementById("card");

turnButton.addEventListener("click", () => {
    cardEl.classList.toggle("turning");

    setTimeout(() => {
        cardEl.classList.toggle("turned");
    }, 400);
});

document.body.addEventListener("keyup", e => {
    let allowedKeys = /[jkl]/,
        keyToElementMap = {
            "k": turnButton,
            "l": correctBtn,
            "j": wrongBtn
        };

    if (allowedKeys.test(e.key)) {
        keyToElementMap[e.key].click();
    }
});


let front = document.getElementById("front-text"),
    back  = document.getElementById("back-text");

front.innerHTML = PIML.parse(front.innerText);
back.innerHTML  = PIML.parse(back.innerText);
