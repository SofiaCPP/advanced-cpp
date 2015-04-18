#include "logtarget.hxx"

FileLogTarget make(const char* name)
{
    return FileLogTarget(Severity::Debug, name);
}

int main()
{
    auto t = make("test.log");
    t.Write(Severity::Warning, "The answer might not be 42\n", 10);
    return 0;
}
