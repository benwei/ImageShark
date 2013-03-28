## Abstract

 ImageShark, a prototype OSX app is small image tool.

### Features
* extract exif and gps info
* convert jpg thumbnail in width or height --> 512

## Howto

### load new image

* [Menu]->[File]->[Open]
* select your file. 
* if image loads successfully, info will be right-side text field.

### export thumbnail

* [Menu]->[File]->[Export]
* if works without, the information for thumbnail creation be at text field.
* The default output directory is your Desktop with filename format

```
format: {filename}_{width}x{height}.jpg

ex: ~/Desktop/{filename}_{width}x{height}.jpg
```

## Contributing
Feel free to fork this repo and commit your enhances. There is a list of Authors file for all contributors

* This project uses Vincent Driessen's [branching model](http://nvie.com/posts/a-successful-git-branching-model/) and [gitflow](https://github.com/nvie/gitflow.git) tool

Steps for submit your contribute
* fork this repository

* new branch from develop

  ```
  ex: git flow feature start <your feature>
  ```
* add your modification to your feature branch

* after complete merger you code to develop

  ```
  ex: git flow feature publish <your feature>

  important: before push your code, please help to use git rebase
  to compose your commits into one. It would be helpful for code review.
  ``` 

* finally, open a pull request to your feature branch.



## License terms

* [Simplified BSD License](http://en.wikipedia.org/wiki/BSD_licenses)

```
Copyright (c) 2013, Ben Wei All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of the FreeBSD Project.
```
