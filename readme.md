## Getting Started

### Requirements

1. [Node.js](http://nodejs.org) at least v0.12.0
2. *bower* - `npm install -g bower`
3. [Hexo](http://hexo.io) 2.8.3 - either globally or locally installed

### Set up

1. Clone the repository
2. `npm install`
3. `bower install`
4. add *node_modules/.bin* to `PATH` to use the locally installed Hexo

### Creating new slides

To create new slides, create a [Jade][http://jade-lang.com] file in
*source/slides* using the following front-matter:

```yaml
layout: slides
title: Overview of C++
path: /slides/01_overview
date: 2015-02-27 01:29:34
tags: slides
---
```

* `section` element denotes a single slide
* `:cxx` filter allows in-line inclusion of C++ sample
* `+snippet` mixing allows inclusion of a snippet from a file. To include the
  *lifetime* snippet from *03_resources/lifetime.cxx* in the current slide use:

    ```jade
    +snippet('03_resources/lifetime.cxx', 'lifetime')
    ```

    And the *lifetime* snippet is defined like:

    ```c++
    //@{ lifetime
    void print(const void* instance, const char* type, const char* msg)
    {
        std::cout << type << ":\t" << instance << ":\t"
            << msg << std::endl;
    }

    struct Lifetime
    {
        Lifetime()
        {
            print(this, "Lifetime", "lives");
        }

        ~Lifetime()
        {
            print(this, "Lifetime", "dies");
        }
    };
    //@} lifetime
    ```

## Hexo Quick Start

### Create a new post

``` bash
$ hexo new "My New Post"
```

More info: [Writing](http://hexo.io/docs/writing.html)

### Run server

``` bash
$ hexo server
```

More info: [Server](http://hexo.io/docs/server.html)

### Generate static files

``` bash
$ hexo generate
```

More info: [Generating](http://hexo.io/docs/generating.html)

### Deploy to remote sites

``` bash
$ hexo deploy
```

More info: [Deployment](http://hexo.io/docs/deployment.html)
