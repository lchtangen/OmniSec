from setuptools import setup, find_packages

setup(
    name="omnisec-ultimate",
    version="3.0.0",
    description="OmniSec ULTIMATE — Cyberpunk 2077 Security Platform",
    long_description="The world's first AI-native, offline-only, post-quantum cybersecurity platform. 161 tools. One CLI. Maximum privacy.",
    author="OmniSec",
    author_email="team@omnisec.io",
    url="https://omnisec.io",
    packages=find_packages(),
    include_package_data=True,
    entry_points={
        "console_scripts": [
            "omnisec=omnisec_desktop.main:main",
            "omnisec-gui=omnisec_desktop.main:run_gui",
        ],
    },
    install_requires=[
        "PyQt6>=6.5.0",
        "PyQt6-sip>=13.5.0",
    ],
    extras_require={
        "full": [
            "ollama",
            "cryptography",
            "requests",
            "fastapi",
            "uvicorn",
        ],
    },
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Environment :: X11 Applications :: Qt",
        "Intended Audience :: Information Technology",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: MIT License",
        "Operating System :: POSIX :: Linux",
        "Operating System :: MacOS",
        "Operating System :: Microsoft :: Windows",
        "Programming Language :: Python :: 3",
        "Topic :: Security",
        "Topic :: System :: Networking",
    ],
    python_requires=">=3.8",
)
