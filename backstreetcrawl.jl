using HTTP
using Cascadia
using Gumbo

function backstreetcrawl(url)
    res = HTTP.get(url)
    body = String(res.body)
    html = parsehtml(body)

    # get links to all pages containing song lyrics
    albums = eachmatch(sel".col-xs-9", html.root);
    links = String[]
    for album in albums
        songs = eachmatch(sel".nested", album)
        for song in songs
            push!(links, song.attributes["href"])
        end
    end

    # GeT AlL ThE LyRiCs
    songurl = split(url, "artist")[1]
    lyrics = String[]
    for link in links
        lres = HTTP.get(joinpath(songurl, split(link, "../")[2]))
        body = String(lres.body)
        html = parsehtml(body)
        lc = eachmatch(sel".lyricsContainer", html.root)
        l = lc[1][4].children
        # separate text and <br>'s
        currentlyrics = String[]
        for i in l
            if typeof(i) == HTMLText
                push!(currentlyrics, text(i))
            elseif typeof(i) == HTMLElement{:br}
                push!(currentlyrics, "\n")
            end
        end
        push!(lyrics, join(currentlyrics))

    end
    return lyrics
end


url = "https://www.songtexte.com/artist/backstreet-boys-33d6a0a5.html"

lyrics = backstreetcrawl(url)
