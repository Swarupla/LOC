
from datetime import datetime
from flask import render_template
from flask import request
from AccentureFileAndLineCount import app
import io
import os
import shutil
from werkzeug.utils import secure_filename
from zipfile import ZipFile
import uuid 
import json
from flask import send_file

# Set the maximum allowed size of an incoming request to 5GB
app.config['MAX_CONTENT_LENGTH'] = 5 * 1024 * 1024 * 1024


@app.route('/')
@app.route('/home')
def home():

    """Renders the home page."""
    return render_template(
        'index.html',
        title='Home Page',
        year=datetime.now().year,
    )
#**************************************************************************************
@app.route('/home/uploadfile',methods=["POST"])
def uploadfile():   
    try:
        # allowed extensions
        allowed_extensions = ['.java', '.rb', '.erb', '.jsp', '.jspx', '.jspf', '.tag', '.tagx', '.tld', '.sql', '.cfm', '.php', '.phtml', '.ctp', '.pks', '.pkh', '.pkb', '.xml', '.config', '.Config', '.settings', '.properties', '.dll', '.exe', '.winmd', '.cs', '.vb', '.asax', '.ascx', '.ashx', '.asmx', '.aspx', '.master', '.Master', '.xaml', '.baml', '.cshtml', '.vbhtml', '.razor', '.inc', '.asp', '.vbscript', '.js', '.jsx', '.ini', '.bas', '.cls', '.vbs', '.frm', '.ctl', '.html', '.htm', '.xsd', '.wsdd', '.xmi', '.py', '.cfml', '.cfc', '.abap', '.xhtml', '.cpx', '.xcfg', '.jsff', '.as', '.mxml', '.cbl', '.cob', '.cscfg', '.csdef', '.wadcfg', '.wadcfgx', '.appxmanifest', '.wsdl', '.plist', '.bsp', '.ABAP', '.BSP', '.swift', '.page', '.trigger', '.scala', '.ts', '.tsx', '.conf', '.json', '.yaml', '.yml', '.tf', '.hcl', '.go', '.kt', '.kts', '.Dockerfile', '.dockerfile']
        # allowed_extensions = ['.txt', '.csv', '.xls', '.xlsx', '.java', '.py', '.ts','.html','.css']
        # excluded extensions
        excluded_extensions = ['.txt', '.pdf', '.doc', '.docx', '.zip', '.rar', '.xlsx', '.xls', '.ppt', '.pptx', '.csv', '.dat', '.jpeg', '.jpg', '.gif', '.svg', '.png', '.TIFF', '.TIF', '.bmp', '.ico', '.xlsm', '.odt', '.exe', '.dll']
        # excluded_extensions = ['.png', '.jpeg']
    
        if 'file' not in request.files:
             return  "No file uploaded"
        file = request.files['file']
        if file.filename == '':
            return  "No file selected"
    
        #*****************************************************************************************
        _datetime = datetime.now()
        datetime_str = _datetime.strftime("%Y-%m-%d-%H-%M-%S")
        # if there are more than one dots
        file_name_split = file.filename.split('.')
        file_name_list = file_name_split[:-1]
        ext = file_name_split[-1]
        file_name_wo_ext = '.'.join(file_name_list)   
        filenamewithExtension=file_name_wo_ext+datetime_str+"."+ext 
        filenamewithoutextensionnwithdate=file_name_wo_ext+datetime_str 
        #*****************************************************************************************
        # create the folders when setting up your app
        # when saving the file
        uploadFolder='upload'
        os.makedirs(os.path.join(app.instance_path, uploadFolder), exist_ok=True)
        file.save(os.path.join(app.instance_path, uploadFolder, secure_filename(filenamewithExtension)))
        #*****************************************************************************************
        #*****************************************************************************************
        #extract zip file
        extractFilepath=os.path.join(app.instance_path, uploadFolder, secure_filename(filenamewithExtension))
        with ZipFile(extractFilepath, 'r') as zObject:
            zObject.extractall(path=os.path.join(app.instance_path,uploadFolder,file_name_wo_ext+datetime_str))
    
        #*****************************************************************************************
        #*****************************************************************************************    
        unzipFolderpath=os.path.join(app.instance_path, uploadFolder, filenamewithoutextensionnwithdate)
        #*****************************************************************************************
        #*****************************************************************************************
    
        totalfilecount = 0
        totallinecount = 0
        lstfileName = []
        for root_dir, cur_dir, files in os.walk(unzipFolderpath):
            totalfilecount += len(files)
            for x in files: 
                # Check if file extension is allowed
                ext = os.path.splitext(x)[1]
                if ext.lower() not in allowed_extensions:
                    continue
                if ext.lower() in excluded_extensions:
                    continue           
                filename=os.path.join(root_dir, x)           
                dictfileDetails =	{}
                dictfileDetails["filename"] = filename
                with open(filename) as f:
                    try:
                        lineinfile = sum(1 for line in f if line.strip())
                        # lineinfile=len(f.readlines())   
                        totallinecount+=lineinfile
                        dictfileDetails["filelineCount"] = lineinfile
                        f.close()
                    except:                   
                        with open(filename, mode="rb") as f:
                            lineinfile = sum(1 for line in f if line.strip())
                            # lineinfile=len(f.readlines())   
                            totallinecount+=lineinfile
                            dictfileDetails["filelineCount"] = lineinfile
                            f.close()
                lstfileName.append(dictfileDetails)# adding dictionay in list

        resultDict={}
        resultDict["fileCount"]=totalfilecount
        resultDict["lineCount"]=totallinecount
        resultDict["returnMessage"]="Size Estimation Completed!"
      
        
        saveFile = request.form.get('saveFile')
        
        if saveFile == 'false':
            folder_to_delete = os.path.join(app.instance_path, uploadFolder, filenamewithoutextensionnwithdate)
            shutil.rmtree(folder_to_delete)
            print("Folder deleted:", folder_to_delete)
            # delete the uploaded zip file
            file.close()
            os.remove(os.path.join(app.instance_path, uploadFolder, secure_filename(filenamewithExtension)))
            print("File deleted:", filenamewithExtension)
        else:
            print("File not deleted:")
            
        return json.dumps(resultDict)
    except Exception as e:
        print(str(e))
        return ''
#**************************************************************************************

    
