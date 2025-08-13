from src.logger import get_logger
from src.exceptions import CustomException
import sys

def test_get_logger():
  logger = get_logger("logger")
  logger.info("This is testing against the logger.")
  assert logger.level == 20
  
def test_divide_number():
  def divide(a, b):
    try:
      result = a/b
      return result
    except Exception as e:
      return CustomException("Custom erro: number divided by zero", sys)
  result = divide(3, 0)
  assert "Custom erro: number divided by zero" in str(result)