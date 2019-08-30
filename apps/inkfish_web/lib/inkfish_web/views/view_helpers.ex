defmodule InkfishWeb.ViewHelpers do
  # Helper functions available in all templates.

  use Phoenix.HTML

  alias Inkfish.Users.User
  alias Inkfish.Users.Reg
  alias Inkfish.Subs.Sub
  alias Inkfish.Grades.Grade
  
  def user_display_name(%User{} = user) do
    "#{user.given_name} #{user.surname}"
  end

  def is_staff?(reg, user) do
    reg.is_staff || reg.is_prof || user.is_admin
  end

  def show_reg_role(%Reg{} = reg) do
    cond do
      reg.is_prof ->
        "prof"
      reg.is_staff ->
        "staff"
      reg.is_student ->
        "student"
      true ->
        "observer"
    end
  end

  def show_score(conn, nil) do
    "∅"
  end

  def show_score(conn, %Sub{} = sub) do
    show_score(conn, sub.score)
  end

  def show_score(conn, %Grade{} = grade) do
    show_score(conn, grade.score)
  end

  def show_score(:show, %Decimal{} = score) do
    ctx = %Decimal.Context{Decimal.get_context | precision: 3}
    Decimal.with_context ctx, fn ->
      score
      |> Decimal.add(Decimal.new("0"))
      |> Decimal.to_string(:normal)
    end
  end

  def show_score(conn, %Decimal{} = score) do
    user = conn.assigns[:current_user]
    reg  = conn.assigns[:current_reg]

    if is_staff?(reg, user) do
      show_score(:show, score)
    else
      course = conn.assigns[:course]
      asgn   = conn.assigns[:assignment]

      grade_hide_secs = 86400 * course.grade_hide_days
      show_at = NaiveDateTime.add(asgn.due, grade_hide_secs)

      now = Inkfish.LocalTime.now()
      if NaiveDateTime.compare(show_at, now) == :lt do
        # Hourglass with Flowing Sand
        "&#9203;"
      else
        show_score(:show, score)
      end
    end
  end

  def assignment_total_points(as) do
    Enum.reduce as.grade_columns, Decimal.new("0"), fn (gcol, sum) ->
      Decimal.add(gcol.points, sum)
    end
  end

  def trusted_markdown(nil), do: "∅"

  def trusted_markdown(code) do
    case Earmark.as_html(code) do
      {:ok, html, []} ->
        raw html
      {:error, html, msgs} ->
        raw "error rendering markdown"
    end
  end

  def sanitize_markdown(nil), do: "∅"

  def sanitize_markdown(code) do
    case Earmark.as_html(code) do
      {:ok, html, []} ->
        raw HtmlSanitizeEx.basic_html(html)
      {:error, html, msgs} ->
        raw "error rendering markdown"
    end
  end

  def ajax_upload_field(kind, exts, target) do
    ~s(<div class="upload-drop-area" data-exts="#{exts}" data-kind="#{kind}"
         data-id-field="#{target}">
         <p class="text-muted">Drag here to upload.</p>
         <div class="row">
           <div class="col-md upload-input">
             <label class="btn btn-secondary btn-file">
               Browse...
               <input type="file" name="_#{target}" style="display: none">
             </label>
           </div>
           <div class="col-md">
             <button class="upload-clear-button btn btn-danger">Clear Upload</button>
           </div>
         </div>
         <div class="row">
           <div class="col">
             <p class="message m-2"></p>
             <div class="progress m-2" style="">
               <div class="progress-bar progress-bar-striped progress-bar-animated p-1">
                 0%
               </div>
             </div>
           </div>
         </div>
       </div>)
    |> raw
  end

  def get_assoc(item, field) do
    data = Map.get(item, field)
    if Ecto.assoc_loaded?(data) do
      data
    else
      nil
    end
  end
end
