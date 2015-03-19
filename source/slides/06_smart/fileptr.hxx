#pragma once

#include <memory>

struct FCloserDeleter
{
    void operator()(FILE* file) const
    {
        if (file)
        {
            fclose(file);
        }
    }
};

typedef std::unique_ptr<FILE, FCloserDeleter> FilePtr;

