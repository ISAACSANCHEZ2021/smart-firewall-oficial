/* terminal typing animation */

const scriptLines = [
    "ubuntu@server:~$ sudo ./smart-firewall.sh",
    "=================================",
    " SMART FIREWALL",
    " Automatic service detection",
    "=================================",
    "Detecting services...",
    "",
    "⚠ Service detected",
    "Program : ssh",
    "Port   : 22",
    "Protocol: tcp",
    "",
    "¿Allow in firewall? (S/n): ",
    "S",
    "",
    "✅ Port 22/tcp allowed",
    "",
    "Scan completed"
]

let term = document.getElementById("terminal")
let line = 0
let char = 0

function type() {

    if (line >= scriptLines.length) return

    let current = scriptLines[line]

    if (char < current.length) {

        term.textContent += current.charAt(char)
        char++
        setTimeout(type, 35)

    } else {

        term.textContent += "\n"
        line++
        char = 0

        let delay = 400

        if (current.includes("(s/n)")) delay = 900

        setTimeout(type, delay)

    }

    term.scrollTop = term.scrollHeight

}

let started = false

const observer = new IntersectionObserver(entries => {
    entries.forEach(e => {
        if (e.isIntersecting && !started) {
            started = true
            setTimeout(type, 500)
        }
    })
}, { threshold: 0.6 })

observer.observe(document.getElementById("terminalBox"))

/* animated network */

const canvas = document.getElementById("network")
const ctx = canvas.getContext("2d")

canvas.width = window.innerWidth
canvas.height = window.innerHeight

let nodes = []

for (let i = 0; i < 80; i++) {

    nodes.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        vx: (Math.random() - 0.5) * 0.4,
        vy: (Math.random() - 0.5) * 0.4

    })

}

function draw() {

    ctx.clearRect(0, 0, canvas.width, canvas.height)

    for (let i = 0; i < nodes.length; i++) {

        let n = nodes[i]

        n.x += n.vx
        n.y += n.vy

        if (n.x < 0 || n.x > canvas.width) n.vx *= -1
        if (n.y < 0 || n.y > canvas.height) n.vy *= -1

        ctx.beginPath()
        ctx.arc(n.x, n.y, 2, 0, Math.PI * 2)
        ctx.fillStyle = "#E95420"
        ctx.fill()

        for (let j = i + 1; j < nodes.length; j++) {

            let m = nodes[j]
            let dist = Math.hypot(n.x - m.x, n.y - m.y)

            if (dist < 130) {

                ctx.beginPath()
                ctx.moveTo(n.x, n.y)
                ctx.lineTo(m.x, m.y)
                ctx.strokeStyle = "rgba(233,84,32,0.1)"
                ctx.stroke()

            }

        }

    }

    requestAnimationFrame(draw)

}

draw()

function closeDonation() {
    document.getElementById("donation-notification").style.display = "none";
}

window.onload = function () {

    setTimeout(function () {

        document.getElementById("donation-notification").classList.add("show");

    }, 1500);

}

function downloadScript(){

const link = document.createElement("a");

link.href = "config/download/smart-firewall.sh"; // ruta del archivo

link.download = "smart-firewall.sh";

document.body.appendChild(link);

link.click();

document.body.removeChild(link);

}