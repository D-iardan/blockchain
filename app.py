from web3 import Web3
from flask import Flask, render_template, request, jsonify
import json


infura_url = 'https://ropsten.infura.io/v3/5e71207af55d4100aef56658c3fa4fa0'
address = '0x32E99CEF5a481F5Ece9d039369D96fcF8779DA2D'
contract_address = '0x894a622D38d341Cc65E6C0c4b2527E77Ab26bA45'
private_key = 'f00cb82eb7c491630cbc468475d2155bdfdbb7eecdce683e706e9ea9cf0807e2'


app = Flask(__name__)

w3 = Web3(Web3.HTTPProvider(infura_url))
w3.eth.defaultAccount = address
with open('rosreestr.abi') as f:
    abi = json.load(f)
contract = w3.eth.contract(address=contract_address, abi=abi)


##Get Balance
#balance = w3.eth.getBalance(address)
#print(w3.fromWei(balance, 'ether'))

##Get Owner
#print(contract.functions.GetOwner().call())


@app.route('/')
def index():
    return render_template("index.html")

@app.route('/addEmployee')
def addEmp():
    return render_template("addemployee.html")


@app.route('/getEmployee')
def getEmp():
    return render_template("getemployee.html")


@app.route('/addRequest')
def addReq():
    return render_template("addrequest.html")

@app.route('/processRequest')
def proReq():
    return render_template("processrequest.html")

@app.route('/addEmployee', methods=['POST'])
def addEmployee():
    nonce = w3.eth.getTransactionCount(address)
    employeeAdrs = request.form.get("employeeAdrs")
    fio = request.form.get("fio")
    eployeePos = request.form.get("eployeePos")
    phoneNum = request.form.get("phoneNum")
    empl_tr = contract.functions.AddEmployee(employeeAdrs, fio , eployeePos, str(phoneNum)).buildTransaction({
        'gas': 3000000,
        'gasPrice': w3.toWei('100', 'gwei'),
        'from': address,
        'nonce': nonce,
    })
    signed_tr = w3.eth.account.signTransaction(empl_tr, private_key=private_key)
    w3.eth.sendRawTransaction(signed_tr.rawTransaction)
    return render_template("addemployee.html")

@app.route('/getEmployee', methods=['POST'])
def getEmployee():
    employeeAdrs = request.form.get("employeeAdrs")
    res = (contract.functions.GetEmployee(employeeAdrs).call())
    return render_template("getemployee.html")+'<p> ФИО: '+str(res[0])+'</p>'+'<p> Должность: '+str(res[1])+'</p>'+'<p> Номер телефона: '+str(res[2])+'</p>'

@app.route('/addRequest', methods=['POST'])
def addRequest():
    nonce = w3.eth.getTransactionCount(address)
    rType = request.form.get("rType")
    homeAddress = request.form.get("homeAddress")
    area = request.form.get("area")
    cost = request.form.get("cost")
    newOwner = request.form.get("newOwner")
    req_tr = contract.functions.AddRequest(int(rType), homeAddress, int(area), int(cost), newOwner).buildTransaction({
        'gas': 3000000,
        'gasPrice': w3.toWei('100', 'gwei'),
        'from': address,
        'nonce': nonce,
        'value':w3.toWei('100','gwei')
    })
    signed_tr = w3.eth.account.signTransaction(req_tr, private_key=private_key)
    w3.eth.sendRawTransaction(signed_tr.rawTransaction) 
    return render_template("addrequest.html")

@app.route('/processrequest', methods=['POST'])
def processRequest():
    nonce = w3.eth.getTransactionCount(address)
    reqId = request.form.get("reqId")
    req_tr = contract.functions.ProcessRequest(int(reqId)).buildTransaction({
        'gas': 3000000,
        'gasPrice': w3.toWei('100', 'gwei'),
        'from': address,
        'nonce': nonce,
    })
    signed_tr = w3.eth.account.signTransaction(req_tr, private_key=private_key)
    w3.eth.sendRawTransaction(signed_tr.rawTransaction) 
    return render_template("processrequest.html")


@app.route('/getRequest')
def getRequest():
    res = (contract.functions.GetRequest().call())
    win = "<table>"
    for column in res:
        win += "<tr>"
        for row in range(len(column)):
            win += "<td>"+str(column[row])+"</td> "
        win += "</tr>"
    win += "</table>"
    return win

@app.route('/getHome')
def getHome():
    res = (contract.functions.GetListHome().call())
    win = "<table>"
    for column in res:
        win += "<tr>"
        for row in range(len(column)):
            win += "<td>"+str(column[row])+"</td> "
        win += "</tr>"
    win += "</table>"
    return win

if __name__ == "__main__":
    app.run(debug=True)