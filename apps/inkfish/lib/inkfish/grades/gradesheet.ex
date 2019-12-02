defmodule Inkfish.Grades.Gradesheet do
  alias Inkfish.Subs.Sub

  def from_course(course) do
    student_scores = for reg <- course.regs do
      scores = student_scores(course, reg)
      {reg.id, scores}
    end
    |> Enum.into(%{})

    stats = course_stats(course, student_scores)

    %{
      students: student_scores,
      stats: stats,
    }
  end

  def d_sort(xs) do
    Enum.sort(xs, &(Decimal.cmp(&1, &2) != :gt))
  end

  def d_median([]), do: nil
  def d_median(xs) do
    xs = d_sort(xs)
    nn = length(xs) - 1
    aa = Enum.at(xs, floor(nn/2))
    bb = Enum.at(xs, ceil(nn/2))
    Decimal.div(Decimal.add(aa, bb), Decimal.new(2))
  end

  def d_mean([]), do: nil
  def d_mean(xs) do
    sum = Enum.reduce(xs, &Decimal.add/2)
    count = Decimal.new(length(xs))
    Decimal.div(sum, count)
  end

  def d_min([]), do: nil
  def d_min(xs) do
    xs |> d_sort() |> hd()
  end

  def d_max([]), do: nil
  def d_max(xs) do
    xs |> d_sort() |> Enum.reverse() |> hd()
  end

  def stats(scores) do
    %{
      median: d_median(scores),
      mean: d_mean(scores),
      min: d_min(scores),
      max: d_max(scores),
    }
  end

  def course_stats(course, scores) do
    buckets = for bucket <- course.buckets do
      bscs = for as <- bucket.assignments do
        scores = for reg <- course.regs do
          scores[reg.id].buckets[bucket.id].scores[as.id]
        end
        |> Enum.filter(&(!is_nil(&1)))
        {as.id, stats(scores)}
      end
      |> Enum.into(%{})

      totals = for reg <- course.regs do
        scores[reg.id].buckets[bucket.id].total
      end

      {bucket.id, %{scores: bscs, total: stats(totals)}}
    end
    |> Enum.into(%{})

    totals = for reg <- course.regs do
      scores[reg.id].total
    end
   
    %{
      buckets: buckets,
      total: stats(totals),
    }
  end

  def student_scores(course, reg) do
    z = Decimal.new("0.0")

    team_subs = Enum.flat_map reg.teams, fn team ->
      team.subs
    end

    buckets = Enum.map course.buckets, fn bucket ->
      scores = for as <- bucket.assignments do
        sub = Enum.find team_subs, &(&1.assignment_id == as.id)
        {as.id, sub_score(sub, as)}
      end
      |> Enum.into(%{})

      score = Enum.reduce bucket.assignments, z, fn (as, sum) ->
        s = scores[as.id] || z
        Decimal.add(sum, Decimal.mult(s, as.weight))
      end
      weight = Enum.reduce bucket.assignments, z, fn (as, sum) ->
        Decimal.add(sum, as.weight)
      end

      total = safe_div(score, weight)

      {bucket.id, %{scores: scores, total: total}}
    end
    buckets = Enum.into(buckets, %{})

    tscore = Enum.reduce course.buckets, z, fn (bucket, sum) ->
      Decimal.add(sum, Decimal.mult(buckets[bucket.id].total, bucket.weight))
    end
    tweight = Enum.reduce course.buckets, z, fn (bucket, sum) ->
      Decimal.add(sum, bucket.weight)
    end

    %{
      buckets: buckets,
      total: Decimal.div(tscore, tweight),
    }
  end

  def sub_score(nil, _), do: nil
  def sub_score(%Sub{score: nil}, _), do: nil
  def sub_score(sub, as) do
    percent(sub.score, as.points)
  end

  def percent(score, points) do
    Decimal.mult(
      Decimal.new("100.0"),
      Decimal.div(score, points)
    )
  end

  defp safe_div(nn, dd) do
    if Decimal.eq?(dd, 0) do
      Decimal.new(0)
    else
      Decimal.div(nn, dd)
    end
  end
end
