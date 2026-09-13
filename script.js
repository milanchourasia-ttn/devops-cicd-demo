document.documentElement.classList.add("js-enabled");

const version = document.querySelector("#version");
if (version) {
  document.title = `DevOps Training v${version.textContent} | CI/CD Pipeline`;
}
