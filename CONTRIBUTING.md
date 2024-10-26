# Elementary Firefox Theme Developer Start Guide

## Turn on Browser Toolbox in Firefox

With this toolbox you can indentify the id's and classes of elements of the browser.

1. In Firefox use Ctrl+Shift+I to open up Web Developer Tools.
2. Open the 3 dots menu and go to Settings (F1).
3. Check `Enable browser chrome and add-on debugging toolboxes` and `Enable remote debugging` and then close Web Developer Tools.
4. Now you can open Browser Toolbox by using Ctrl+Shift+Alt+I or go to Menu > More Tools > Browser Toolbox.
5. Use the `Pick an element from the page` button (first button upper left) to select and identify a browser element.

## Edit base.css

To edit elements in the Browser you need to open `base.css` in your profile directory in the `chrome` folder. The profile folder you can find when you type `about:profiles` in the url bar. When you open the profile folder you can find a chrome folder in it, if you installed the theme of course. Open `base.css` in Code to start editing it.

If you want to change an element in the browser, you have selected it with Browser Toolbox and know the elements id or class, then you can search in Code for that exact name in `base.css`. This way you see what styling is there already for that element and you can start experimenting with the values to make it behave the way you want it.

If the element doesn't exist in `base.css`, then you can add it. Try to add it under a chapter. For example `base.css` starts with chapter `MENU POPUPS + right mouse click menus`, under this chapter you can put any element that has to do with menus and right click menus.

**Note:** I have tried to put as many chapters in `base.css` as I could, but for example the private mode section is a bit messy. This is because a lot of elements needed to become white colored so I had put them all under one chapter `ELEMENTS IN PRIVATE MODE`. I have tried to devide buttons and other elements in chapters so be sure they are under the right chapter when you add one.

## Other css files

The other css files are `userChrome.css` and `userContent.css` and `flatpak.css`. The `userChrome.css` file is all about the positions of window control buttons layout (close, minimize and maximize buttons). The `userContent.css` is about the dark theme in the home page of Firefox. The `flatpak.css` is about the changes needed for the flatpak version of Firefox. For example when editing something in the flatpak version of Firefox, it needs to be edited in `flatpak.css`.

If you use `Private Mode Style` or `Titlebar Enabled` theme then you also have a `userChrome.css` just for that special theme.

**Note:** The `userChrome.css` is always the main file that is used by Firefox to theme the browser. That is why `userChrome.css` for a window control button layout imports `base.css` to make the browser theme complete.

## Fork and clone

1. After editing the css's, you can now fork and clone your fork by following this: [Contributing to projects](https://docs.github.com/en/get-started/quickstart/contributing-to-projects).
2. After all is set you can copy and overwrite the edited css's to the cloned directory locally and push the changes to your fork online.
3. You can now make a pull request to my repository and explain your changes in the message option.

*Thanks in advance for your contribution and happy theming!*
