(function() {
    let turnButton = document.getElementById("turn"),
        correctBox = document.getElementById("answerCorrect"),
        wrongBox   = document.getElementById("answerWrong"),
        nextButton = document.getElementById("nextBtn"),
        cardEl     = document.getElementById("card");

    turnButton.addEventListener("click", () => {
        cardEl.classList.toggle("turning");

        setTimeout(() => {
            cardEl.classList.toggle("turned");
        }, 400);
    });

    document.body.addEventListener("keyup", e => {
        let allowedKeys = /[jknt]/,
            keyToElementMap = {
                "t": turnButton,
                "j": correctBox,
                "k": wrongBox,
                "n": nextButton
            };

        if (allowedKeys.test(e.key)) {
            keyToElementMap[e.key].click();
        }
    });
}());
