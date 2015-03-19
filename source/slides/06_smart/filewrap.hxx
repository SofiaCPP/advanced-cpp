#pragma once

class FilePtr
{
public:
    FilePtr()
        : _file(nullptr)
    {}

    FilePtr(FILE* file)
        : _file(file)
    {}

    ~FilePtr()
    {
        if (_file)
        {
            fclose(_file);
            _file = nullptr;
        }
    }

    FilePtr(const FilePtr&) = delete;

    FilePtr(FilePtr&& other)
       : _file(other._file)
    {
        other._file = nullptr;
    } 

    FilePtr& operator=(const FilePtr&) = delete;

    FilePtr& operator=(FilePtr&& other)
    {
        std::swap(_file, other._file);
        return *this;
    }

    FILE* get()
    {
        return _file;
    }

private:
    FILE* _file;
};
