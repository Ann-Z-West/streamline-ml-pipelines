import traceback
import sys

class CustomException(Exception):
  def __init__(self, error_msg, error_details:sys):
    super().__init__(error_msg)
    self.error_msg = self.get_detailed_error_message(error_msg, error_details)
  
  @staticmethod
  def get_detailed_error_message(error_msg, error_details:sys):
    _, _, exc_tb = error_details.exc_info()
    file_name = exc_tb.tb_frame.f_code.co_filename
    line_number = exc_tb.tb_lineno
    return f"Error occurs in {file_name} at line {line_number}: {error_msg}"
  
  def __str__(self):
    return self.error_msg