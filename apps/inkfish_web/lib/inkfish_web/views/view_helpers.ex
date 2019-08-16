defmodule InkfishWeb.ViewHelpers do
  # Helper functions available in all templates.

  use Phoenix.HTML

  alias Inkfish.Users.User
  alias Inkfish.Users.Reg
  
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

  def staff_reg?(reg) do
    reg && (reg.is_staff || reg.is_prof || reg.user.is_prof)
  end

  def show_score(item) do
    if item && item.score do
      item.score
    else
      "∅"
    end
  end

  def assignment_total_points(as) do
    Enum.reduce as.graders, Decimal.new("0"), fn (gdr, sum) ->
      Decimal.add(gdr.points, sum)
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
end
