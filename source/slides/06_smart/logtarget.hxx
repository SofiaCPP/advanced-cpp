#pragma once

#include <cstdio>
#include "fileptr.hxx"

enum class Severity
{
    Silent,
    Error,
    Warning,
    Info,
    Debug,
    Trace,
};

class ILogTarget
{
public:
    virtual ~ILogTarget() = 0;
    virtual void Write(Severity severity, const char* message, int length) = 0;
};

inline ILogTarget::~ILogTarget() {}

class FileLogTarget : public ILogTarget
{
public:
    FileLogTarget(Severity severity, const char* file)
        : _file(fopen(file, "wb")), _severity(severity)
    {
    }

    virtual void Write(Severity severity, const char* message, int length)
    {
        if (severity <= _severity)
        {
            fwrite(message, sizeof(char), length, _file.get());
        }
    }

    //FileLogTarget(FileLogTarget&&) = default;

private:
    FilePtr _file;
    Severity _severity;
};
