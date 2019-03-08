# HackSoc EmailMD
This is a tweaked variant of Markdown which can be used to create HackSoc
weekly emails.

The only addition on top of regular Markdown is the _section_, which is denoted
by `%`. For example:

```
% Section One
This is section one's content.
Lorem ipsum...

% Section Two
This is the second section.

```

The difference between headings and sections is that sections are block-style
elements which wrap all content afterwards until the next section. This is
required to give the emails pretty markup. Here's how the ASTs of headings and
sections would look, to further show the difference:

```

Document:         # 1                      % 1
                  A                        A

                  # 2                      % 2
                  B                        B


Tree:             root                     root
                    |                        |
              -------------                -----
             /    |   |    \              /     \
           # 1    A  # 2    B           % 1     % 2
                                         |       | 
                                         A       B
```

Another much less significant change is that `hr` now has some extra styling
to make it suitable for dividing the items in the _"The Timetable"_ section of
the weekly emails.

## Usage
Use this as a command-line tool with one argument, the document to compile.
After running `chmod +x hsemailmd.rb`, you can use this tool like so:

```
./hsemailmd.rb <filename>
```

Output HTML is printed, so you'll want to pipe it into a file.

## Things about emails

- Gmail doesn't support SVGs :(
- Most clients don't support web fonts. You can use fonts which the client
    loaded though, if you want to; for example, web Gmail is able to display
    Google Sans in emails. 
- If you need a block element for something, `table` is a _much_ safer bet
    than `div`. `div` support is really spotty in almost every single
    client. Even Gmail, which is relatively modern, acts aggressively towards
    `div`s, sometimes removing their CSS or the entire tag.
- Stick to inline styles; many clients discard `style` tags entirely.
    - Speaking of styles, Gmail doesn't appear to like single-quotes in CSS. It
        seems to throw away the _entire_ `style` attribute if it contains one.
- Even using them seems like a good idea, base64 images have mediocre support
    and don't work very well in Gmail. I'm hosting images on Runciman instead.
    (I wouldn't need to if Gmail supported SVG...)
- iOS deserves extra testing, as it can sometimes decide that an email should
    be a different size and shift everything to one side, leaving a big ugly
    white gap. If you'd like to test efficiently, start a Litmus trial.