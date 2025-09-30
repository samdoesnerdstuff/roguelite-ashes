# roguelite-ashes

![Static Badge](https://img.shields.io/badge/Built_with-Lua-blue?logo=lua&logoColor=%23FFFFFF)

![Static Badge](https://img.shields.io/badge/Source_Code-CC--BY--NC--SA--4.0-white?logo=creativecommons&logoColor=%23FFFFFF)
![Static Badge](https://img.shields.io/badge/Game_Assets-CC--BY--ND--NC--4.0-white?logo=creativecommons&logoColor=%23FFFFFF)

Built in Lua, this is a "source-available" repository for an in-development game that will be published to Steam sometime in March of 2026. This game is licensed under the following licenses;
 - For **Source Code** (all content written in Lua, C or Make): the license is [CC-BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
 - For **Game Assets** (Music, sprites, other art): the license is [CC-BY-ND-NC 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/)

I am committed to transparent development, which is why the source code is freely available to the community for learning and non-commercial use. The distinction in licensing ensures that while I can still benefit from contributions and feedback on the code, I can also protect the copyrighted art and music assets to fund ongoing development and make a sustainable commercial product.

> [!NOTE]
> Contributions of code to this project will get your GitHub username (or another name if you prefer) put in the in-game credits sequence. By submitting a contribution, you agree that your code will be licensed under the same terms as this repository and will be included in the commercial product.

---

Now that the boring but mandatory legal preface is out of the way... welcome to the canonical respository for *Within Ashes!* This is all the source code for the project, this isn't a mirror, this is **the actual source code.** Changes here mean changes to the Steam release. This is a "source-available" repository, the short explaination is that the games assets are under a more restrictive license than the source code. Under the conditions of the source code license you are more than free to clone this repo and play around with it and your own art, however to get the assets used by this game in release, you will need a valid copy from Steam.

This game is built on top of Love2D and MSYS2 (MSYS is a GNU-like environment for Windows and I used it to build the Lua->Steam APIs). [Love2D](https://love2d.org/) is an *awesome* framework for building 2D games in Lua. I chose it since it provides a perfect blend of development speed and runtime speed. Lua is also a fairly easy to grasp language, many resources are available to understand and master Lua in a few weeks.

It should be noted that this game does *not* have the best coding practices implemented at all times. Sometimes there are cases of *magical numbers* in a function draft unless its an intentional constant value. While this is *inherently* not great, it does allow for a small uptick in developer speed overall, but most of this issues will be ironed out in later commits to improve the entire codebase. I'm always hard at work when it comes to improving the codebase and the project in general, if you spot instances of bad code or poorly-performant code, make a note with an issue, please!
