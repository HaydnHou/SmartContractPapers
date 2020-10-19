controller控制服务的接口来控制业务流程，也可以通过接收前端传来的参数进行业务操作。
service（业务逻辑层）主要针对具体的问题的操作，把一些数据层的操作进行组合，间接与数据库打交道
mapper（数据存储对象）mapper直接与数据库打交道，接口提供给服务层



控制器--->接收前端传来的参数
    |
   控制
    |
 服务--->针对具体的问题操作
    |
间接连接数据库
    |
  mapper --->提供给服务接口，直接与数据库打交道



实体层dto，pojo，model，domain， 

mapper也叫dao层，操作数据库层 

service包含了serviceImpl，提供给controller使用

controller交互前端，控制服务接口。




mapper直接连接数据库操作层
List <Map> eventList（@Param（“ keywords”）字符串关键字，@ Param（“ eventId”）长eventId）;

miletaskeventMapper.xml文件控制数据库操作
<mapper namespace =“ com.eec.information.mapper.EventMapper”>
    <select id =“ eventList” resultType =“ java.util.Map”>
        select
        t1.id，t1.code，t1.sm_code，t1.title，t1.description，t2.id AS aId，t2.code AS aCode
        from
        tra_milestone_tasknode_event t1，tra_milepost t2
        where
        t1.sm_code = t2.code
        <if test =“ eventId！= null”>
            AND t1.id =＃{eventId}
        </ if>
    </ select>
</ mapper>


服务层service层/add


​        
```java
    @Override
    public Class1DTO add(Class1DTO class1DTO) {
    	isTrue((nonNull(classDTO)), ErrorEnum.ENTITY_NOT_NULL.getMessage());
			BeanConverter<Class1DTO, Class1> beanConverter = new BeanConverter<>();  
   		Class1 class1 = beanConverter.convertToPO(class1DTO, Class1.class);
    	class1Mapper.insertSelective(class1);
     /*调整格式符合前端显示 
    List<TraMilestoneTasknodeDTO> traMilestoneTasknodeDTOS = traMilestoneDTO.getTraMilestoneTasknodeDTOS();
    for (TraMilestoneTasknodeDTO traMilestoneTasknodeDTO:traMilestoneTasknodeDTOS) {
        BeanConverter<TraMilestoneTasknodeDTO, TraMilestoneTasknode> beanConverter1 = new BeanConverter<>();
        TraMilestoneTasknode traMilestoneTasknode = beanConverter1.convertToPO(traMilestoneTasknodeDTO, TraMilestoneTasknode.class);
        traMilestoneTasknode.setSm_code(traMilestone.getCode());
        traMilestoneTasknode.setSm_id(traMilestone.getId());
        traMilestoneTasknodeMapper.insertSelective(traMilestoneTasknode);
    }*/
    return beanConverter.convertToDTO(class1, Class1DTO.class);
}


 @Override
    public MilepostDTO add(MilepostDTO milepostDTO) {   
        isTrue((nonNull(milepostDTO)), ErrorEnum.ENTITY_NOT_NULL.getMessage());
        BeanConverter<MilepostDTO, Milepost> beanConverter = new BeanConverter<>();
        Milepost milepost = beanConverter.convertToPO(milepostDTO, Milepost.class);
        milepostMapper.insertSelective(milepost);
        return beanConverter.convertToDTO(milepost, MilepostDTO.class);
    }
```





控制器层
私有EventService eventService; //控制服务界面
//接收前端传来的参数
```java
@PostMapping（“ / add”）
    公共ModelMap add（@Validated @RequestBody EventDTO eventDTO）{
        返回成功（eventService.add（eventDTO））; //控制服务界面
    }
    @PostMapping（“ / edit”）
    公开ModelMap编辑（@Validated @RequestBody EventDTO eventDTO）{
        返回成功（eventService.update（eventDTO））; //控制服务界面
    }
    @PostMapping（“ / del / {id}”）
    public ModelMap delete（@PathVariable（“ id”）长id）{
        eventService.delete（id）; //控制服务接口
        返回成功（）;
    }
    @PostMapping（“ / list”）
    公共ModelMap列表（@RequestBody（required = false）EventDTO eventDTO）{
        返回成功（eventService.findPage（eventDTO），true）;
    } //接收前端传来的参数
```

