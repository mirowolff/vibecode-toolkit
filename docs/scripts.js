function copyCommand(event) {
    event.stopPropagation();
    const cmd = 'curl -fsSL https://mirowolff.github.io/vibecode-toolkit/install.sh | bash';
    navigator.clipboard.writeText(cmd).then(() => {
        const btn = document.querySelector('.copy-btn');
        const terminalBox = document.querySelector('.terminal-content');
        const copyIcon = btn.querySelector('.copy-icon');
        const checkIcon = btn.querySelector('.check-icon');

        btn.classList.add('copied');
        terminalBox.classList.add('copied');
        copyIcon.style.display = 'none';
        checkIcon.style.display = 'block';

        setTimeout(() => {
            btn.classList.remove('copied');
            terminalBox.classList.remove('copied');
            copyIcon.style.display = 'block';
            checkIcon.style.display = 'none';
        }, 2000);
    });
}

function copyCommandFromBox(element) {
    const cmd = 'curl -fsSL https://mirowolff.github.io/vibecode-toolkit/install.sh | bash';
    navigator.clipboard.writeText(cmd).then(() => {
        const btn = document.querySelector('.copy-btn');
        const copyIcon = btn.querySelector('.copy-icon');
        const checkIcon = btn.querySelector('.check-icon');

        btn.classList.add('copied');
        element.classList.add('copied');
        copyIcon.style.display = 'none';
        checkIcon.style.display = 'block';

        setTimeout(() => {
            btn.classList.remove('copied');
            element.classList.remove('copied');
            copyIcon.style.display = 'block';
            checkIcon.style.display = 'none';
        }, 2000);
    });
}

// View Transitions API for smooth page navigation
if (document.startViewTransition) {
    // Intercept same-origin navigation
    window.addEventListener('click', (e) => {
        const link = e.target.closest('a');
        if (!link) return;

        const url = new URL(link.href);
        const isSameOrigin = url.origin === location.origin;
        const isNotExternal = !link.hasAttribute('target');

        if (isSameOrigin && isNotExternal) {
            e.preventDefault();

            document.startViewTransition(() => {
                window.location = url.href;
            });
        }
    });
}

// Keyboard support for terminal box
document.addEventListener('DOMContentLoaded', () => {
    const terminalBox = document.querySelector('.terminal-content');
    if (terminalBox) {
        terminalBox.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                copyCommandFromBox(terminalBox);
            }
        });
    }

    // Mobile menu toggle
    const menuBtn = document.querySelector('.mobile-menu-btn');
    const navLinks = document.querySelector('.nav-links');

    if (menuBtn && navLinks) {
        menuBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            navLinks.classList.toggle('active');
        });

        // Close menu when clicking outside
        document.addEventListener('click', (e) => {
            if (!navLinks.contains(e.target) && !menuBtn.contains(e.target)) {
                navLinks.classList.remove('active');
            }
        });

        // Close menu when clicking a link
        navLinks.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', () => {
                navLinks.classList.remove('active');
            });
        });
    }

    // Collapsible sections
    const collapsibleHeaders = document.querySelectorAll('.collapsible-header');

    collapsibleHeaders.forEach(header => {
        header.addEventListener('click', () => {
            const section = header.parentElement;
            const isActive = section.classList.contains('active');

            // Toggle active state
            section.classList.toggle('active');

            // Update aria-expanded attribute
            header.setAttribute('aria-expanded', !isActive);
        });

        // Keyboard support
        header.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                header.click();
            }
        });
    });
});
