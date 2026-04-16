module IssuesHelper
  def sortable(column, title = nil)
    title ||= column.titleize

    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"

    icon = if column == params[:sort]
             direction == "asc" ? " ▲" : " ▼"
    else
             ""
    end

    link_to "#{title}#{icon}".html_safe, request.query_parameters.merge(sort: column, direction: direction), class: "sort-link", style: "color: inherit; text-decoration: none;"
  end
end
