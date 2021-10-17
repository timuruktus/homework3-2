pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract TaskList { 

    uint32 public timestamp;
    mapping (int8=>task) taskMap;
    int8[] taskKeys;
    int8 constant DELETED_KEY = -1;

    struct task {
        uint256 creationTime;
        string name;
        bool done;
    }


    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        timestamp = now;
    }

    modifier ifTaskKeyExist(int8 taskKey) {
        tvm.accept();
        bool taskKeyExist = false;
        require(taskKey > DELETED_KEY, 201);
        for(uint i = 0; i < taskKeys.length; i++){
            if(taskKeys[i] == taskKey){
                taskKeyExist = true;
            }
        }
        require(taskKeyExist, 201);
        _;
    }

    function addTask(string name) public{
        tvm.accept();
        int8 mappingLength = int8(taskKeys.length);
        task newTask = task(now, name, false);
        taskMap[mappingLength] = newTask;
        taskKeys.push(mappingLength);
    }

    function getTasksAmount() public view returns(uint256){
        tvm.accept();
        uint256 amount = 0;
        for(uint256 i = 0; i < taskKeys.length; i++){
            if(taskKeys[i] != DELETED_KEY){
                amount++;
            }
        }
        return amount;
    }

    function getTasks() public view returns(task[]){
        tvm.accept();
        task[] tasks;
        for(uint256 i = 0; i < taskKeys.length; i++){
            if(taskKeys[i] != DELETED_KEY){
                tasks.push(taskMap[taskKeys[i]]);
            }
        }
        return tasks;
    }


    function getTaskDescription(int8 taskKey) public view ifTaskKeyExist(int8(taskKey)) returns(string){
        tvm.accept();
        return taskMap[int8(taskKey)].name;
    }


    function deleteTask(int8 taskKey) public ifTaskKeyExist(int8(taskKey)){
        tvm.accept();
        delete taskMap[int8(taskKey)];
        taskKeys[uint(taskKey)] = DELETED_KEY;
    }

    function markTaskDone(int8 taskKey) public ifTaskKeyExist(int8(taskKey)){
        tvm.accept();
        taskMap[int8(taskKey)].done = true;
    }



}
