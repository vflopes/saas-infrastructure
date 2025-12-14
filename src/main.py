import configparser
config = configparser.ConfigParser()
config.read("envs.ini")
  
if __name__ == "__main__":
    print("Hello, World!")