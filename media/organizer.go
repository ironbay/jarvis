package media

import (
    "github.com/ironbay/jarvis/cortex"
    "io/ioutil"
    "os"
    "regexp"
    "strings"
    "time"
)

type FileDownload struct {
    Path string
    Name string
}

type FileDeleted struct {
    Path string
    Name string
}

func (f *FileDownload) Alert() string {
    return "Finished downloading: " + f.Name
}

func init() {

    root := "/media/uncategorized/"
    tv := "/media/tv/"
    movie := "/media/movies/"

    var clean = func(context *cortex.Context) {
        for _, p := range []string{tv, movie} {
            r, _ := ioutil.ReadDir(p)
            now := time.Now()
            for _, f := range r {
                if now.Sub(f.ModTime()).Hours() > (30 * 24) {
                    m := FileDeleted{
                        Path: p + "/" + f.Name(),
                        Name: f.Name()}
                    os.Remove(m.Path)
                    cortex.Event.Emit(&m, context)
                }
            }
        }
    }

    cortex.Cron.AddFunc("@daily", func() {
        clean(cortex.NoContext())
    })

    var classify = func(context *cortex.Context) {
        r, _ := ioutil.ReadDir(root)
        for _, p := range r {
            cortex.Event.Emit(&FileDownload{
                Path: root + p.Name(),
                Name: p.Name()}, context)
        }
    }

    cortex.Event.Listen(func(m *TorrentFinished, context *cortex.Context) {
        if ok, _ := regexp.MatchString("(avi|mp4|mkv)$", m.Path); ok {
            info, err := os.Stat(m.Path)
            if err != nil {
                cortex.Event.Error(err.Error(), context)
                return
            }
            data, _ := ioutil.ReadFile(m.Path)
            ioutil.WriteFile(root+info.Name(), data, 0755)
        } else {
            cortex.Process.Run("unrar -r e " + m.Path + "/*.rar " + root)
            r, _ := ioutil.ReadDir(m.Path)
            for _, p := range r {
                ok, _ := regexp.MatchString("(avi|mp4|mkv)$", p.Name())
                if !ok {
                    continue
                }
                data, _ := ioutil.ReadFile(m.Path + "/" + p.Name())
                ioutil.WriteFile(root+p.Name(), data, 0755)
            }
        }
        classify(context)
    })

    regex := []*regexp.Regexp{
        regexp.MustCompile("(.+)\\W(\\d{4})"),
        regexp.MustCompile("(.+)\\Ws\\d"),
        regexp.MustCompile("(.+)\\W\\d")}

    cortex.Event.Listen(func(m *FileDownload, context *cortex.Context) {
        output := movie
        lower := strings.ToLower(m.Name)
        if strings.Contains(lower, "sample") {
            os.Remove(m.Path)
            return
        }
        if strings.Contains(lower, "hdtv") {
            output = tv
            for _, r := range regex {
                matches := r.FindStringSubmatch(lower)
                if len(matches) > 0 {
                    output += matches[1] + "/"
                    break
                }
            }
            os.MkdirAll(output, 0775)
        }
        output += m.Name
        os.Rename(m.Path, output)
        os.Chtimes(output, time.Now(), time.Now())
    })

    classify(cortex.NoContext())
}
