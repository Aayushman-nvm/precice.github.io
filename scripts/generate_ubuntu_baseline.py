#!/usr/bin/env python3

import subprocess
import yaml
import argparse
from pathlib import Path
from datetime import datetime

ROOT = Path(__file__).resolve().parent.parent
DEPENDENCIES_FILE = ROOT / "scripts" / "dependencies.yml"
OUTPUT_FILE = ROOT / "_data" / "ubuntu-baseline.yml"


def load_dependencies():
    with open(DEPENDENCIES_FILE, "r") as f:
        data = yaml.safe_load(f)
    return sorted(data.get("packages", []))


def run_command(cmd):
    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if result.returncode != 0:
        print(result.stderr)
        return None
    return result.stdout.strip()


def get_version_docker(ubuntu_version, package):
    cmd = [
        "docker",
        "run",
        "--rm",
        f"ubuntu:{ubuntu_version}",
        "bash",
        "-c",
        f"apt-get update -qq && apt-cache policy {package} | grep Candidate | awk '{{print $2}}'",
    ]
    return run_command(cmd)


def get_version_mock(package):
    return "0.0.0-mock"


def generate_data(lts_versions, mock=False):
    packages = load_dependencies()
    result = {
        "generated_at": datetime.utcnow().isoformat() + "Z",
        "ubuntu": {},
    }

    for version in lts_versions:
        result["ubuntu"][version] = {}

        for pkg in packages:
            if mock:
                ver = get_version_mock(pkg)
            else:
                ver = get_version_docker(version, pkg)

            result["ubuntu"][version][pkg] = ver or "not-found"

    return result


def write_yaml(data):
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_FILE, "w") as f:
        yaml.dump(data, f, sort_keys=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mock", action="store_true")
    parser.add_argument(
        "--lts",
        nargs="+",
        required=True,
        help="Ubuntu LTS versions (e.g. 22.04 24.04)"
    )
    args = parser.parse_args()

    data = generate_data(args.lts, mock=args.mock)
    write_yaml(data)

    print(f"Generated {OUTPUT_FILE}")


if __name__ == "__main__":
    main()