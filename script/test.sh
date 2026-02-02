#!/bin/bash

CONTRACT_ADDRESS=$(./script/deploy.sh Counter)
EXIT_CODE=$?

# Check if deploy.sh failed
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: Deployment failed with exit code $EXIT_CODE" >&2
    exit $EXIT_CODE
fi

echo "Contract address: $CONTRACT_ADDRESS"