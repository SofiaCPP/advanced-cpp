struct IButtonHandler
{
    virtual ~IButtonHandler() = 0;
    virtual void OnClick() const = 0;
};

class ButtonI
{
    ButtonI(std::unique_ptr<IButtonHandler> h)
    {
    }

    std::unique_ptr<IButtonHandler> m_Handler;
};


class ButtonFun
{
    ButtonFun(std::function<void()> handler)
        : m_Handler(handler)
    {
    }
    std::function<void()> m_Handler;
};

class ButtonSig
{
    template <typename Fun>
    void AddHandler(Fun f)
    {
        m_Handlers += f;
    }
    void AddHandler(std::function<void()> f)
    {
        m_Handlers += f;
    }
    boost::signal<void()> m_Handlers;
};
