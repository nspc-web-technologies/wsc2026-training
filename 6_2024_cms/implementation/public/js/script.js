const dialog = document.getElementById("dialog");
const dialogImg = dialog.querySelector("img");

document.querySelectorAll(".flex img").forEach(function (img) {
    img.addEventListener("click", function (event) {
        dialogImg.src = img.src;
        dialog.showModal();
    })
})

function closeDialog() {
    dialog.close();
    dialogImg.src = "";
}

addEventListener("scroll", function () {
    dialog.close();
})

const circle = document.querySelector(".mv .circle");

document.querySelector(".mv").addEventListener("mousemove", function (event) {
    circle.style.left = event.offsetX + "px";
    circle.style.top = event.offsetY + "px";
});