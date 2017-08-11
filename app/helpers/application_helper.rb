module ApplicationHelper
  
  def format_datetime(time, format)
    
    case format
      when 'md'
        time.strftime("%m/%d")
      when 'mdy'
        time.strftime("%m/%d/%y")
      else 'mdyhm'
        time.strftime("%m/%d/%y %l:%M%P")
      end
  end
  
end
