let slideIndex = 0;

function showSlides() {
    let slides = document.getElementsByClassName("slide");
    for (let i = 0; i < slides.length; i++) {
        slides[i].style.display = "none";  
    }
    slideIndex++;
    if (slideIndex > slides.length) {slideIndex = 1}    
    slides[slideIndex-1].style.display = "block";  
    setTimeout(showSlides, 4000); // Chuyển slide sau 4 giây
}

showSlides(); // Bắt đầu slideshow

function showDropdown() {
    document.querySelector('.dropdown-menu').classList.add('show');
}

function hideDropdown() {
    document.querySelector('.dropdown-menu').classList.remove('show');
}

document.addEventListener("DOMContentLoaded", function () {
    const dropdownBtn = document.getElementById("dropdownBtn");
    const dropdownMenu = document.getElementById("dropdownMenu");

    dropdownBtn.addEventListener("click", function (event) {
        event.stopPropagation(); // Ngăn chặn sự kiện lan ra ngoài
        dropdownMenu.classList.toggle("show");
    });

    // Đóng dropdown khi click bên ngoài
    document.addEventListener("click", function (event) {
        if (!dropdownBtn.contains(event.target) && !dropdownMenu.contains(event.target)) {
            dropdownMenu.classList.remove("show");
        }
    });
});
document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".add-to-cart").forEach(button => {
        button.addEventListener("click", function (event) {
            event.preventDefault();

            let productId = this.getAttribute("data-id");

            fetch("/cart/add", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-TOKEN": document.querySelector('meta[name="csrf-token"]').getAttribute("content")
                },
                body: JSON.stringify({ id: productId })
            })
            .then(response => response.json())
            .then(data => {
                document.querySelector(".cart-count").innerText = data.cart_count;
                alert(data.message);
            })
            .catch(error => console.error("Lỗi:", error));
        });
    });

    // Load số lượng sản phẩm trong giỏ hàng khi trang tải
    fetch("/cart/count")
        .then(response => response.json())
        .then(data => {
            document.querySelector(".cart-count").innerText = data.cart_count;
        });
});

document.addEventListener("DOMContentLoaded", function () {
    fetch("/cart/count")
        .then(response => response.json())
        .then(data => {
            document.querySelector(".cart-count").innerText = data.cart_count;
        });
});







