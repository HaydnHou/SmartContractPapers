controller控制服务的接口来控制业务流程，也可以通过接收前端传来的参数进行业务操作。
service（业务逻辑层）主要针对具体的问题的操作，把一些数据层的操作进行组合，间接与数据库打交道
mapper（数据存储对象）mapper直接与数据库打交道，接口提供给服务层



controller--->接收前端传来的参数
    |
   控制
    |
 service--->针对具体的问题操作
    |
间接连接数据库
    |
  mapper --->提供给服务接口，直接与数据库打交道



实体层dto，pojo，model，domain， 

mapper也叫dao层，操作数据库层 

service包含了serviceImpl，提供给controller使用

controller交互前端，控制服务接口。

```java

@RestController
@RequestMapping("/Classname")
public class ClassnameController {
    @Resource
    private ClassnameService classnameService;//高节点service
    @Resource
    private DiClassnameService diclassnameService;//低节点service
    @Resource
    private ZaidiClassnameService zaidiclassnameService;//再低节点service
    @Resource
    private HttpServletRequest request;//httpservlet request
    //添加
    @PostMapping("/add")
    public ModelMap add(@Validated @RequestBody ClassnameDTO classnameDTO) {
        classnameDTO.setStatus(0);//设置状态为0
        return success(classnameService.add(classnameDTO));//返回添加成功
    }
    //编辑
    @PostMapping("/edit")
    public ModelMap edit(@Validated @RequestBody ClassnameDTO classnameDTO) {
        return success(classnameService.update(classnameDTO));//返回编辑成功
    }
    //删除
    @PostMapping("/del/{id}")
    public ModelMap delete(@PathVariable("id") Long id) {
        classnameService.delete(id);//通过ID删除
        return success();
    }

    @PostMapping("/info")
    public ModelMap info(Long classnameId) {//通过ID查找，然后显示
        return success(traMilestoneService.getByID(classnameId), true);
    }
    
    @PostMapping("/list")
    public ModelMap list(@RequestBody TraMilestoneDTO traMilestoneDTO) {//list查找 通过ID的值，返回findpage的所有数据
        return success(traMilestoneService.findPage(traMilestoneDTO));
    }

    @GetMapping(value = "/findAll")
    public Object findAll(){//查找所有
        return traMilestoneService.findAll();//返回
    }

    @PostMapping(value="/findPage")
    public Object findPage(@RequestBody PageRequest pageQuery) {
        return traMilestoneService.findPage(pageQuery);
    }

    @RequestMapping("/save")
    @ResponseBody
    public String save(TraMilestoneDTO traMilestoneDTO) {//保存
        traMilestoneService.save(traMilestoneDTO);
        return "save success !";
    }

    /**
     * 校级院级查看认证进度
     * @param traMilestoneDTO
     * @return
     */
    @PostMapping("/certifyList")
    public ModelMap certifyList(@RequestBody(required = false) TraMilestoneDTO traMilestoneDTO) {
        return success(traMilestoneService.findPageByAcademyIdAndSpecialyId(traMilestoneDTO), true);
    }

    /**
     * 查看专业下所有里程碑
     * @param specialyId
     * @return
     */
    @GetMapping("/findAllMilestoneBySpecialyId")
    public ModelMap findAllMilestoneBySpecialyId(Long specialyId) {
        return success(traMilestoneService.findAllMilestone(specialyId), true);
    }

    /**
     * 查看里程碑下节点
     * @param milestoneId
     * @return
     */
    @GetMapping("/findTaskNodeInfo")
    public ModelMap findTaskNodeInfo(Long milestoneId) {
        List<TraMilestoneTasknode> traMilestoneTasknodes = traMilestoneService.findTaskNodeInfo(milestoneId);
        List<Map> list = new ArrayList<>();
        for (int i = 0; i < traMilestoneTasknodes.size(); i++) {
            TraMilestoneTasknode traMilestoneTasknode = traMilestoneTasknodes.get(i);
            Map map = new HashMap();
            map.put("taskId",traMilestoneTasknode.getId());
            map.put("taskName",traMilestoneTasknode.getTitle());
            map.put("taskCode",traMilestoneTasknode.getCode());
            map.put("status",traMilestoneTasknode.getStatus());
            List<TraMilestoneAffairDTO> events = traMilestoneAffairService.getByTaskID(traMilestoneTasknode.getId());
            map.put("events",events);
            list.add(map);
        }
        return success(list, true);
    }

    /**
     * 添加批示
     * @param eventId
     * @return
     */
    @GetMapping("/addReply")
    public ModelMap addReply(Long eventId,String reply) {
        TraMilestoneAffairDTO entity = traMilestoneAffairService.getByID(eventId);
        entity.setReply(reply);
        LoginUser userInfo = getLoginUser(request);
        entity.setReplyer(userInfo.getUserName());
        entity.setReplyerId(userInfo.getSysUserID());
        entity.setReplyDate(new Date());
        traMilestoneAffairService.update(entity);
        return success();
    }

    /**
     * 事件列表
     * @param taskId
     * @return
     */
    @GetMapping("/events")
    public ModelMap events(Long taskId) {
        List<TraMilestoneAffairDTO> entity = traMilestoneAffairService.getByTaskID(taskId);
        return success(entity,true);
    }

    /**
     * 批示列表
     * @param taskId
     * @return
     */
    @GetMapping("/replys")
    public ModelMap replys(Long taskId) {
        List<Map> entity = traMilestoneAffairService.replys(taskId);
        return success(entity,true);
    }
```



服务层service层

```java
public interface TraMilestoneService {//接口

    ClassnameDTO add(ClassnamrDTO classnameDTO);//新增
    ClassnameDTO update(ClassnameDTO classnameDTO);// 修改 
    List<Map> batchSort(Map paramMap);
    ClassnameDTO getByID(Long id);// 根据ID查询信息
    void delete(Long id);//删除  
    PageInfo<Map> findPage(ClassnameDTOeclassnamrDTO); //分页查询
    PageInfo<Map> findPageByAcademyIdAndSpecialyId(ClassnameDTO classnameDTO);// 分页查询认证进度
    List<TraMilestone> findAllMilestone(Long specialyId);//查询专业下所有里程碑
    List<TraMilestoneTasknode> findTaskNodeInfo(Long milestoneId);// 查询里程碑下节点和事件   
    List<Map> findEventInfo(Long taskId);//查询里程碑下节点和事件
    List<Map> getList();
    List<TraMilestone> findAll();//查询所有里程碑
    /**
     * 分页查询接口
     * @param pageRequest 自定义，统一分页查询请求
     * @return PageResult 自定义，统一分页查询结果
     */
    PageResult findPage(PageRequest pageRequest);
    TraMilestoneDTO save(TraMilestoneDTO traMilestoneDTO);//保存
}
```


​        
```java
 //实现
@Service
@Transactional(isolation = Isolation.DEFAULT,propagation = Propagation.REQUIRED,readOnly = false)
public class ClassnameServiceImpl implements ClassnameService {
    @Autowired//自动注入mapper
    ClassnameMapper classnameMapper;//高节点类mapper
    @Autowired//自动注入mapper
    DiClassnameMapper diclassnameTasknodeMapper;//低节点类mapper
    @Resource//
    BaseService baseService;//beseService基础service
  
@Override//add
    public MilepostDTO add(MilepostDTO milepostDTO) {   
        isTrue((nonNull(milepostDTO)), ErrorEnum.ENTITY_NOT_NULL.getMessage());
        BeanConverter<MilepostDTO, Milepost> beanConverter = new BeanConverter<>();
        Milepost milepost = beanConverter.convertToPO(milepostDTO, Milepost.class);
        milepostMapper.insertSelective(milepost);
        return beanConverter.convertToDTO(milepost, MilepostDTO.class);
    }
@Override//update
    public MilepostDTO update(MilepostDTO milepostDTO) {
        BeanConverter<MilepostDTO, Milepost> beanConverter = new BeanConverter<>();
        isTrue((nonNull(milepostDTO) && nonNull(milepostDTO.getId())), ErrorEnum.PRIMARYKEY_NOT_NULL.getMessage());
        Milepost milepost = milepostMapper.selectByPrimaryKey(milepostDTO.getId());
        isTrue(nonNull(milepost), ErrorEnum.ENTITY_IS_NOT_EXIST.getMessage());
        copyProperties(milepostDTO, milepost, SysConstant.IGNORE_PROPERTIES);
        milepostMapper.updateByPrimaryKeySelective(milepost);
        return beanConverter.convertToDTO(milepost,MilepostDTO.class);   
    }
 @Override//delete
    public void delete(Long id) {
     		 Milepost milepost = new Milepost();
//        isTrue(nonNull(id), ErrorEnum.PRIMARYKEY_NOT_NULL.getMessage());
//        Classname classname = new Classname();
//        classname.setId(id);
//        classname.setIsDeleted(1);
//        classnameDao.updateByPrimaryKeySelective(classname);    
       	 milepostMapper.delete(milepost);
    }

}


		@Override///add增 
    public ClassnameDTO add(ClassnameDTO classnameDTO) {
    	isTrue((nonNull(classnameDTO)), ErrorEnum.ENTITY_NOT_NULL.getMessage());//是否为空
			BeanConverter<ClassnameDTO, Classname> beanConverter = new BeanConverter<>();  //new BeanConverter
   		Classname classname = beanConverter.convertToPO(classnameDTO, Classname.class);// new classname注入BeanConverter
    	classnameMapper.insertSelective(classname);//insert增加
     /*调整格式符合前端显示 
    List<TraMilestoneTasknodeDTO> traMilestoneTasknodeDTOS = traMilestoneDTO.getTraMilestoneTasknodeDTOS();
    for (TraMilestoneTasknodeDTO traMilestoneTasknodeDTO:traMilestoneTasknodeDTOS) {
        BeanConverter<TraMilestoneTasknodeDTO, TraMilestoneTasknode> beanConverter1 = new BeanConverter<>();
        TraMilestoneTasknode traMilestoneTasknode = beanConverter1.convertToPO(traMilestoneTasknodeDTO, TraMilestoneTasknode.class);
        traMilestoneTasknode.setSm_code(traMilestone.getCode());
        traMilestoneTasknode.setSm_id(traMilestone.getId());
        traMilestoneTasknodeMapper.insertSelective(traMilestoneTasknode);
    }*/
    return beanConverter.convertToDTO(class1, Class1DTO.class);//返回beanConverter
}




 @Override//update改
    public ClassnameDTO update(ClassnameDTO classnameDTO) {
        BeanConverter<ClassnameDTO, Classname> beanConverter = new BeanConverter<>();//new BeanConverter
        isTrue((nonNull(classnameDTO) && nonNull(classnameDTO.getId())), ErrorEnum.PRIMARYKEY_NOT_NULL.getMessage());//是否为空
      
        Classname classname = classnameMapper.selectByPrimaryKey(classnameDTO.getId());//获取为ID的类
        isTrue(nonNull(classname), ErrorEnum.ENTITY_IS_NOT_EXIST.getMessage());//是否为空
        copyProperties(classnameDTO, classname, SysConstant.IGNORE_PROPERTIES);//修改数据
        classnameMapper.updateByPrimaryKeySelective(classname);//修改
      /*调整格式符合前端显示
        List<TraMilestoneTasknodeDTO> traMilestoneTasknodeDTOS = traMilestoneDTO.getTraMilestoneTasknodeDTOS();
        for (TraMilestoneTasknodeDTO traMilestoneTasknodeDTO:traMilestoneTasknodeDTOS) {
            BeanConverter<TraMilestoneTasknodeDTO, TraMilestoneTasknode> beanConverter1 = new BeanConverter<>();
            TraMilestoneTasknode traMilestoneTasknode = beanConverter1.convertToPO(traMilestoneTasknodeDTO, TraMilestoneTasknode.class);
            if(traMilestoneTasknode.getId()!=null){
                traMilestoneTasknodeMapper.updateByPrimaryKeySelective(traMilestoneTasknode);
            }else{
                traMilestoneTasknode.setSm_code(traMilestone.getCode());
                traMilestoneTasknodeMapper.insertSelective(traMilestoneTasknode);
            }
        }*/
        return beanConverter.convertToDTO(classname, ClassnameDTO.class);//返回结果
       
    }


 @Override//delete删
    public void delete(Long id) {
        TraMilestone traMilestone = new TraMilestone();
      //删除其余下属于它的子分类
        traMilestone.setId(id);//获取父id
        TraMilestoneTasknode traMilestoneTasknode = new TraMilestoneTasknode();//new 子类
        traMilestoneTasknode.setSm_id(id);//与父ID相同的子sm_id
        List<TraMilestoneTasknode> traMilestoneTasknodes = traMilestoneTasknodeMapper.select(traMilestoneTasknode);//list
        for (TraMilestoneTasknode traMilestoneTasknode1:traMilestoneTasknodes){//遍历循环所有，删除
            traMilestoneTasknodeMapper.delete(traMilestoneTasknode1);
        }
        traMilestoneMapper.delete(traMilestone);//删除
    }



 @Override//find查找
    public TraMilestoneDTO getByID(Long id) {
        BeanConverter<TraMilestoneDTO, TraMilestone> beanConverter = new BeanConverter<>();// new BeanConverter
        BeanConverter<TraMilestoneTasknodeDTO, TraMilestoneTasknode> beanConverter1 = new BeanConverter<>();
      	//new BeanConverter 父类下的子类
      
        TraMilestone traMilestone = traMilestoneMapper.selectByPrimaryKey(id); //选择为ID的父类
        TraMilestoneDTO traMilestoneDTO1 = beanConverter.convertToDTO(traMilestone, TraMilestoneDTO.class);
     	 //注入为ID的beanConverter
      
        TraMilestoneTasknode traMilestoneTasknode = new TraMilestoneTasknode();//new 子类
        traMilestoneTasknode.setSm_code(traMilestone.getCode());//获取sm_code为父ID的子类
        List<TraMilestoneTasknode> traMilestoneTasknodes = traMilestoneTasknodeMapper.select(traMilestoneTasknode);//list
        List<TraMilestoneTasknodeDTO> traMilestoneTasknodeDTOS = new ArrayList<>();//list
        for (TraMilestoneTasknode traMilestoneTasknode1:traMilestoneTasknodes){//遍历循环找所有
            TraMilestoneTasknodeDTO traMilestoneTasknodeDTO = beanConverter1.convertToDTO(traMilestoneTasknode1, TraMilestoneTasknodeDTO.class);
            traMilestoneTasknodeDTOS.add(traMilestoneTasknodeDTO);
        }
        traMilestoneDTO1.setTraMilestoneTasknodeDTOS(traMilestoneTasknodeDTOS);
        return traMilestoneDTO1;//返回
    }


 @Override//findPage分页查找
    public PageInfo<Map> findPage(TraMilestoneDTO traMilestoneDTO) {
        PageHelper.startPage(traMilestoneDTO.getPage(),traMilestoneDTO.getRows());//pagehelper import导入类 获取row
        TraMilestone traMilestone2= new TraMilestone();//new 类
        List<TraMilestone> traMilestones = traMilestoneMapper.select(traMilestone2);//list
        List<TraMilestoneDTO> traMilestoneDTOS = new ArrayList<>();//list
        BeanConverter<TraMilestoneDTO, TraMilestone> beanConverter = new BeanConverter<>();//new BeanConverter
        BeanConverter<TraMilestoneTasknodeDTO, TraMilestoneTasknode> beanConverter1 = new BeanConverter<>();
      	//new BeanConverter
      
        for (int i = 0; i < traMilestones.size(); i++) {//循环查找所有
            TraMilestone traMilestone = traMilestones.get(i);
            TraMilestoneDTO traMilestoneDTO1 = beanConverter.convertToDTO(traMilestone, TraMilestoneDTO.class);
            TraMilestoneTasknode traMilestoneTasknode = new TraMilestoneTasknode();
            traMilestoneTasknode.setSm_code(traMilestone.getCode());
            List<TraMilestoneTasknode> traMilestoneTasknodes = traMilestoneTasknodeMapper.select(traMilestoneTasknode);
            List<TraMilestoneTasknodeDTO> traMilestoneTasknodeDTOS = new ArrayList<>();
            for (TraMilestoneTasknode traMilestoneTasknode1:traMilestoneTasknodes){
                TraMilestoneTasknodeDTO traMilestoneTasknodeDTO = beanConverter1.convertToDTO(traMilestoneTasknode1, TraMilestoneTasknodeDTO.class);
                traMilestoneTasknodeDTOS.add(traMilestoneTasknodeDTO);
            }
            traMilestoneDTO1.setTraMilestoneTasknodeDTOS(traMilestoneTasknodeDTOS);
            traMilestoneDTOS.add(traMilestoneDTO1);
        }
       PageInfo pageInfo = new PageInfo(traMilestoneDTOS);
       return pageInfo;
    }
  


 @Override//find通过学院ID和专业id查找
    public PageInfo<Map> findPageByAcademyIdAndSpecialyId(TraMilestoneDTO traMilestoneDTO) {
        PageHelper.startPage(traMilestoneDTO.getPage(),traMilestoneDTO.getRows());//pagehelper import导入类 获取row
        List<Map> paList = traMilestoneMapper.findPageByAcademyIdAndSpecialyId(traMilestoneDTO.getAcademyId(),traMilestoneDTO.getSpecialtyId());
      //list
        PageInfo pageInfo = new PageInfo(paList);//new pageinfo   
        return pageInfo;//返回
    }

    @Override//find所有，通过专业ID
    public List<TraMilestone> findAllMilestone(Long specialyId) {
        TraMilestone traMilestone = new TraMilestone();//new class
        traMilestone.setSpecialtyId(specialyId); //找到相同的specilyId
        return traMilestoneMapper.select(traMilestone);//返回所有选中的
    }

    @Override//find所有，通过父id，找子类中相同的父id
    public List<TraMilestoneTasknode> findTaskNodeInfo(Long milestoneId) {
        TraMilestoneTasknode traMilestoneTasknode = new TraMilestoneTasknode();//new 子类
        traMilestoneTasknode.setSm_id(milestoneId); //找
        traMilestoneTasknode.setRows(0);//初始row赋值0
        return traMilestoneTasknodeMapper.select(traMilestoneTasknode);//返回所有选中的
    }

    @Override//find所有，通过父ID，找子类中相同的父ID，同上。
    public List<Map> findEventInfo(Long taskId) {
        TraMilestoneTasknode traMilestoneTasknode = new TraMilestoneTasknode();
        traMilestoneTasknode.setSm_id(taskId);
        return null;
    }


/**
     * 调用分页插件完成分页
     * @param
     * @return
     */
    private PageInfo<TraMilestone> getPageInfo(PageRequest pageRequest) {
        int pageNum = pageRequest.getPageNumber();
        int pageSize = pageRequest.getPageSize();
        PageHelper.startPage(pageNum, pageSize);
        List<TraMilestone> sysMenus = traMilestoneMapper.selectPage();
        return new PageInfo<TraMilestone>(sysMenus);
    }


    @Override//保存
    public ClassnameDTO save(ClassnameDTO classnameDTO) {
//      return classnameDao.save(classnameDTO);
        classnameMapper.save(classnameDTO);
        return null;
    }
```



mapper直接连接数据库操作层

```java
@Repository
public interface TraMilestoneMapper extends BaseMapper<TraMilestone> {

    List<Classname> findPage(Classname classname);//list
    List<Map> classnameList(@Param("keywords") String keywords, @Param("Id") Long Id);//list
    List<Classname> selectAll();//查找所有
    List<Classname> selectPage();//分页查询
    void save(ClassnameDTO classnameDTO);//保存

    @Select(mysql语言)
  
    List<Map> findPageByAcademyIdAndSpecialyId(@Param("academyId") Long academyId,@Param("specialtyId") Long specialtyId);
}
```


```java

```

