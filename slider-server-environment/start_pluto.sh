#/usr/bin/env bash

julia -e 'print(VERSION); using Pkg; Pkg.activate("./slider-server-environment"); import PlutoSliderServer; PlutoSliderServer.run_directory("./notebooks/"; SliderServer_port=1234, SliderServer_host="0.0.0.0")'
