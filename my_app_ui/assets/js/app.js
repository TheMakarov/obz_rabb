// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()


// custom events declared here !

window.addEventListener("phx:show_modal", (event) => {
  const modal = document.getElementById(event.detail.id);
  modal.style.display = "flex";
});

window.addEventListener("phx:hide_modal", (event) => {
  const modal = document.getElementById(event.detail.id);
  modal.style.display = "none";
});

window.liveSocket = liveSocket;

let tabs = [
  "telemetry",
  "devices",
  "wifi",
  "dmesg",
  "system"
];

// tabs.forEach((tab) => {
//   console.log(document.getElementsByClassName(tab)[0]);
//   document.getElementsByClassName(tab)[0].addEventListener('click', (event) => {
//     this.pushEvent("select_tab", { selected_tab: event.originalTarget.className });
//     showTab(tab);
//   });
// });

function showTab(tabId) {
  document.querySelectorAll('.tab-content').forEach(section => {
    section.classList.add('hidden');
  });
  document.getElementById(tabId).classList.remove('hidden');
}

document.addEventListener("DOMContentLoaded", () => {
  // Smooth scrolling
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      e.preventDefault();
      document.querySelector(this.getAttribute('href')).scrollIntoView({
        behavior: 'smooth'
      });
    });
  });
});

function sortTable(n) {
  const table = document.getElementById("telemetry-table");
  let switching = true, shouldSwitch, switchCount = 0;
  let direction = "asc", rows, i, x, y;

  while (switching) {
    switching = false;
    rows = table.rows;
    for (i = 1; i < (rows.length - 1); i++) {
      shouldSwitch = false;
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];
      if (direction == "asc") {
        if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
          shouldSwitch = true;
          break;
        }
      } else if (direction == "desc") {
        if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      switchCount++;
    } else {
      if (switchCount == 0 && direction == "asc") {
        direction = "desc";
        switching = true;
      }
    }
  }
}

// let popup_classes  = [
//   "close-btn"
// ];

// popup_classes.forEach((clas) => {
//   console.log(document.getElementsByClassName(clas)[0]);
//   document.getElementsByClassName(clas)[0].addEventListener('click',
//     (e) => {
//       console.log(e);
//       document.getElementsByClassName('popup').forEach((elem) => elem.style.display = 'none');
//     }
//   )
// });

function showPopup(clas) {
  document.getElementsByClassName(clas)[0].classList.add('active');
}

function closePopup(clas) {
  document.getElementsByClassName(clas).classList.remove('active');
}

function showSecurityOptions() {
  const security = document.getElementById('security').value;
  const securityOptions = document.getElementById('security-options');
  securityOptions.innerHTML = '';

  if (security !== 'none') {
    const label = document.createElement('label');
    label.setAttribute('for', 'password');
    label.textContent = 'Password:';
    securityOptions.appendChild(label);

    const input = document.createElement('input');
    input.setAttribute('type', 'password');
    input.setAttribute('id', 'password');
    securityOptions.appendChild(input);
  }
}
