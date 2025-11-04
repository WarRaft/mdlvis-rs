#!/bin/bash

# Build and run mdlvis-rs with test model
set -e

echo "Building mdlvis-rs..."
cargo build --release

echo "Running with Arthas test model..."
./target/release/mdlvis-rs test-data/Arthas.mdx