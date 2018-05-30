# 需要引入的jar
```   
<dependency>
    <groupId>commons-net</groupId>
    <artifactId>commons-net</artifactId>
    <version>3.4</version>
</dependency>```

# java 代码
```
public class UploadData2FTPTask {

	private static final Logger logger = LoggerFactory.getLogger(DeviceServiceImpl.class);

	@Autowired
	private PhoneInfoMapper phoneInfoMapper;
	private FTPClient ftpClient;
	@Value("${ftpServerAddr}")
	private String ftpServerAddr;//ftp服务器地址
	@Value("${ftpServerPort}")
	private int ftpServerPort;//ftp服务器端口
	@Value("${ftpServerUser}")
	private String ftpServerUser;//ftp服务器用户
	@Value("${ftpServerPass}")
	private String ftpServerPass;//ftp服务器密码
	@Value("${ftpServerDir}")
	private String ftpServerDir;//ftp服务器接收文件的相对目录，相对于ftp服务器的根目录而言
	@Value("${ftpLocalTmpDir}")
	private String ftpLocalTmpDir;//本地缓存ftp待上传文件的目录

    public void ftpPut() throws Exception {
        //创建文件，文件写入流
		File file = mkFile();
    try (BufferedWriter bw = new BufferedWriter(new FileWriter(file))) {
			bw.write("Hello Ftp PUT");//写入txt
		} catch (IOException e) {
			e.printStackTrace();
			logger.error("ftp数据写入文件失败", e);
			logger.info("ftp reply:" + ftpClient.getReplyString());
		}
		//ftp上传文件
		if (connectFtp()){
			if(StringUtils.isNotEmpty(ftpServerDir)&& !ftpServerDir.equals("\\")){
				mkRemoteDir(ftpServerDir);
				//切换ftp服务器当前目录
				changeWorkingDirectory(ftpServerDir);
			}
			//上传待上传区的文件，避免上次有文件没上传成功，所以迭代当前目录
			for (File f:file.getParentFile().listFiles()){
				uploadFile(f);
			}
		}
		closeConnect();
	}

	/**
	 * 返回一个ftp客户端的连接
	 * @return 是否连接成功
	 */
	private boolean connectFtp() {
		boolean flag = true;
		try {
			if (ftpClient==null) {
				ftpClient = new FTPClient();
			}
			if(!ftpClient.isConnected()){
				ftpClient.connect(ftpServerAddr, ftpServerPort);
			}
			ftpClient.login(ftpServerUser, ftpServerPass);
			int reply = ftpClient.getReplyCode();
			ftpClient.setDataTimeout(180000);//1000*60*3
			if (!FTPReply.isPositiveCompletion(reply)) {
				ftpClient.disconnect();
			}
			// 开启服务器对UTF-8的支持，服务器支持用UTF-8编码，
			if (FTPReply.isPositiveCompletion(ftpClient.sendCommand("OPTS UTF8", "ON"))) {
				ftpClient.setControlEncoding("UTF-8");
			}
			ftpClient.enterLocalPassiveMode();// 设置被动模式
			//设置传输的模式<code> FTP.ASCII_FILE_TYPE </code>, <code> FTP.BINARY_FILE_TYPE</code>,
			ftpClient.setFileType(FTP.ASCII_FILE_TYPE);
			ftpClient.setBufferSize(65536);//1024*64
		}catch (SocketException e) {
			flag=false;
			logger.error("登录ftp服务器 " + ftpServerPort + " 失败,连接超时！",e);
		} catch (IOException e) {
			logger.error("登录ftp服务器 " + ftpServerPort + " 失败，FTP服务器无法打开！",e);
			flag=false;
		}
		logger.info("ftp reply:"+ftpClient.getReplyString());
		return flag;
	}

	/**
	 * 上传文件到ftp服务器
	 * @param file file
	 * @throws Exception 异常
	 */
	@Transactional
	public void uploadFile(File file) throws Exception {
		if (file.isFile()) {
			FileInputStream input = new FileInputStream(file);
			if(ftpClient.storeFile(new String(file.getName().getBytes("UTF-8"),"iso-8859-1"), input)){
				//标记数据已经修改
				phoneInfoMapper.markDataHadFtp();
				logger.info(file.getAbsolutePath()+"上传文件成功！");
				if (null!= input) {
					input.close();
				}
				file.delete();//流关闭后删除文件
			}else{
				logger.warn(file.getAbsolutePath()+"上传文件失败！");
				logger.info("ftp reply:"+ftpClient.getReplyString());
			}
		}
	}
	/**
	 * 关闭ftp客户端连接
	 */
	private void closeConnect() {
		try {
			if (ftpClient != null) {
				ftpClient.logout();
				ftpClient.disconnect();
			}
		} catch (Exception e) {
			e.printStackTrace();
			logger.error("关闭ftp连接失败",e);
		}
	}
	/**
	 * 进入到ftp服务器的某个目录下
	 *
	 * @param directory 目录
	 */
	private boolean changeWorkingDirectory(String directory) {
		boolean flag = true;
		try {
			ftpClient.changeWorkingDirectory("/");
			flag = ftpClient.changeWorkingDirectory(directory);
			if (flag) {
				logger.info("进入ftp服务器指定文件夹"+ directory + " 成功！");
			} else {
				logger.warn("进入ftp服务器指定文件夹"+ directory + " 失败！");
				logger.info("ftp reply:"+ftpClient.getReplyString());
			}
		} catch (IOException ioe) {
			ioe.printStackTrace();
			logger.error("切换远程目录失败",ioe);
			logger.info("ftp reply:"+ftpClient.getReplyString());
		}
		return flag;
	}
	/**
	 * 在服务器上创建一个文件夹
	 * @param dir 文件夹名称，不能含有特殊字符，如 \ 、/ 、: 、* 、?、 "、 <、>...
	 */
	private boolean mkRemoteDir(String dir) {
		boolean flag = true;
		try {
			flag = ftpClient.makeDirectory(dir);
			if (flag) {
				logger.info("创建ftp服务器指定文件夹"+ dir + " 成功！");
			} else {
				logger.error("创建ftp服务器指定文件夹"+ dir + " 失败！");
				logger.info("ftp reply:"+ftpClient.getReplyString());
			}
		} catch (Exception e) {
			logger.error("创建服务器目录失败",e);
			logger.info("ftp reply:"+ftpClient.getReplyString());
		}
		return flag;
	}

	/**
	 * 创建并返回一个待上传文件，以便写入带上出数据
	 * @return 可写入数据的文件
	 */
	private File mkFile() {
		File dir = new File(ftpLocalTmpDir);
		if(!dir.exists()){
			dir.mkdirs();
		}
		String fileName ="ftp_"+new SimpleDateFormat("yyyyMMdd").format(new Date()) +"_data.txt";
		File f = new File(dir,fileName);
		if(!f.exists()){
			try {
				f.createNewFile();
			} catch (IOException e) {
				logger.error("创建文件失败："+ftpLocalTmpDir+"/"+fileName,e);
			}
		}
		return f;
	}
}
```
