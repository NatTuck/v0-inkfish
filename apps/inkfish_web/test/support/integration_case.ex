defmodule InkfishWeb.IntegrationCase do
 use ExUnit.CaseTemplate

 using do
    quote do
      use InkfishWeb.ConnCase
      use PhoenixIntegration
    end
  end
end
