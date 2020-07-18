@echo off

pushd %~dp0
powershell -ExecutionPolicy Unrestricted -NoLogo -File .\BuildProject.ps1 %1
popd