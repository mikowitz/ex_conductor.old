defmodule ExConductor.Lilypond do
  def generate_score(instruments) do
    score = ~s"""
    \\version "2.22.0"
    \\language "english"

    \\header {
      tagline = ##f
    }

    \\score {
      <<
        #{generate_staves(instruments)}
      >>
    }
    """

    Application.get_env(:ex_conductor, :png_generator_fn).(score)
  end

  def generate_png(score) do
    {:ok, f} = File.open("score.ly", [:write])
    IO.puts(f, score)
    File.close(f)

    System.cmd("lilypond", ["--png", "score.ly"])
    System.cmd("convert", ["-trim", "score.png", "score.png"])

    {:ok, png} = File.read("score.png")
    # File.rm("score.ly")
    # File.rm("score.svg")
    Base.encode64(png)
  end

  defp generate_staves(instruments) do
    instruments
    |> Enum.map(&generate_staff/1)
    |> Enum.join("\n")
  end

  defp generate_staff(instrument) do
    ~s"""
    \\new Staff = "#{instrument}" \\with {
      instrumentName = #"#{instrument}"
    } {
      #{Stream.repeatedly(&generate_note/0) |> Enum.take(8) |> Enum.join(" ")}
      c'4
    }
    """
  end

  def generate_note do
    Enum.random(~w(a b c d e f g cs ef fs af bf)) <> "'"
  end
end
