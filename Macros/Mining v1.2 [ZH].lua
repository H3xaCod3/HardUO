--===========================================================================--
-- Macro: Mining Minoc.
-- Programa de Script: HardUO - http://www.hogpog.com.br/harduo
-- Escrito por Alex (Blue)
-- Versao: 1.2
-- Shard: Zulu Hotel - http://www.zuluhotel.com.br
-- Descri�ao: Mining Minoc (Minera, vai ao banco, guarda e volta pra mina)
--===========================================================================--

--Configura�ao de peso m�ximo ate ir no banco guardar
PesoMaximo = 40

mMiningDirections = { {-1,-1},{0,-1},{1,-1},{-1,0},{0,0},{1,0},{-1,1},{0,1},{1,1} }
mCurrentDirections = 1

--mOreTypes = {6585,6584,6586,6583}--dwj_ewj_gwj_tvj
mOreTypes = typeConverter("DWJ_EWJ_GWJ_TVJ")
mJewelTypes={3864, 3857, 3859, 3878, 3855, 3861, 3862} --pe,tu,bd,fr,ba,ec,ds
mMesssages ={"too far","Nao ha nada", "no ore left", "uma linha", "muito distante", "Tente minerar em", "perto", "so close", 
             "can't see", "You can't" , "completa"}
function GoToBank()
    Move(2560,494,0,15000)
    Move(2558,501,0,15000)
    Move(2540,502,0,15000)
    Move(2526,502,0,15000)
    Move(2526,513,0,15000)
    Move(2510,513,0,15000)
    Move(2510,542,0,15000)
end

function GoToMine()
    Move(2510,542,0,15000)
    Move(2510,513,0,15000)
    Move(2526,513,0,15000)
    Move(2526,502,0,15000)
    Move(2540,502,0,15000)
    Move(2558,501,0,15000)
    Move(2560,494,0,15000)
end

function GetPicaxeFromBank()
    GoToBank()
    Speak("bank")
    wait(500)
    for i=1,5 do
    pickaxe = FindItem({Type={3717,3718}})
        if #pickaxe <=0 then
            UO.SysMessage("Sem pickaxe manolo!!")
            print("Sem pickaxe manolo!! == parando macro == linha 48 ==")
        end
        wait(250)
    end
    UO.Drag(pickaxe[1].id)
    wait(400)
    UO.DropC(UO.BackpackID)
    wait(400)
    DepositOres()
    GoToMine()
end

function DepositOres()
  Speak("bank")
  wait(500)
  ores = FindItem({Type=mOreTypes,ContID=UO.BackpackID})
  if #ores>0 then
    for i=1, #ores do
      --UO.SysMessage("ore "..ores[i].ID.." stack "..ores[i].Stack)
      UO.Drag(ores[i].id, ores[i].stack)
      wait(400)
      UO.DropC(mBankBag)
      wait(400)
    end
  end
  ores = FindItem({Type=mJewelTypes,ContID=UO.BackpackID})

  if #ores>0 then
    for i=1, #ores do
      UO.Drag(ores[i].id, ores[i].stack)
      wait(400)
      UO.DropC(mBankBag)
      wait(400)
    end
  end
end

local nNewRef = 0
function getMsg()
    nNewRef, nCnt= UO.ScanJournal(nNewRef) 
    local sLine = UO.GetJournal(0)
    local a = {}
    while nCnt > 0 do
        a[nCnt] = UO.GetJournal(nCnt)
        nCnt = nCnt -1
    end
    return a
end
function findMsg(mstr, find)
    for i=1, #mstr do
        for n=1,#find do
            if(string.find(mstr[i],find[n])) then
                return true
            end
        end
    end
end
function NewSpot()
    --[lateral da mina
    x = math.random(2568,2578)
    --[frente e fundo (nao ta muito pra frente pra evitar PK)
    y = math.random(474,485)      
    Move(x,y,1,5000)
    TargetMining()         
end

function TargetMining()
  tmp = mMiningDirections[mCurrentDirections]
  mCurrentDirections = mCurrentDirections+1
  --[se ele ja procurou tudo em volta do char, manda andar
  if mCurrentDirections > 10 then
     mCurrentDirections = 1
     NewSpot()
  end     
  UO.LTargetX = tmp[1] + UO.CharPosX
  UO.LTargetY = tmp[2] + UO.CharPosY
  UO.LTargetZ = UO.CharPosZ       
  UO.LTargetKind = 3
end

function StartMining()
    while true do
        pickaxe = FindItem({Type={3717,3718}})
        if #pickaxe <= 0 then
            GetPicaxeFromBank()
        end
        if UO.Weight > PesoMaximo then
            GoToBank()
            DepositOres()
            GoToMine()
        end
        pickaxe = FindItem({Type={3717,3718}})
        UO.LObjectID =  pickaxe[1].id
        EventMacro(17,0)
        wait(300)
        EventMacro(25, 0)
        wait(150)
        EventMacro(22,0)    
        mContinue = true
        mTime = 0
        --[enquanto o tempo for menor que 8k e nao tiver mensagem de erro da lista
        while mContinue and mTime < 8000 do
            if(UO.Hits < UO.MaxHits) then
                Speak(".guards")
            end
            journal = getMsg()
            if(findMsg(journal,mMesssages)) then
                TargetMining()
                mContinue = false
                break
            end
            mTime = mTime + 100
            wait(100)
        end
    end
end


UO.ScanJournal(1)
UO.SysMessage("Va ate o banco e aperte a tecla Enter")
WaitKey(KEY_ENTER)
Speak("bank")
UO.SysMessage("Selecione a bag de minerios")
UO.TargCurs = 1
while UO.TargCurs == 1 do
    wait(10)
end
mBankBag = UO.LTargetID

pickaxe = FindItem({Type={3717,3718}})
if #pickaxe <=0 then
    UO.SysMessage("Sem pickaxe manolo!!")
    print("Sem pickaxe manolo!!")
    return
end
UO.Drag(pickaxe[1].id)
wait(400)
UO.DropC(UO.BackpackID)
wait(400)

GoToMine()
UO.Msg(".autoloop 1"..string.char(13))
NewSpot()
TargetMining()
StartMining()