#!/bin/bash

engine=$(ibus engine)
if [[ "$engine" = "Unikey" ]]; then
	echo "VN"
else
	echo "EN"
fi
