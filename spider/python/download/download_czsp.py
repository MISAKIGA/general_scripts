from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor  # 线程池，进程池
import threading
import time
import requests
import json
import os

class ThreadPoolMan():
    def __init__(self, max_thread):
        # 线程池+线程同步改造添加代码处1/5： 定义锁和线程池
        # 我们第二大节中说的是锁不能在线程类内部实例化，这个是调用类不是线程类，所以可以在这里实例化
        self.threadLock = threading.Lock()
        # 定义10个线程的线程池
        self.thread_pool = ThreadPoolExecutor(max_thread)
        # 定义2个进程的进程池。进程池没用写在这里只想表示进程池的用法和线程池基本一样
        # self.process_pool = ProcessPoolExecutor(max_thread)
        pass

    # 线程池+线程同步改造添加代码处2/5： 添加一个通过线程池调用do_task的中间方法。参数与do_task一致
    def call_do_task(self, para):
        # 控制未完成任务数添加代码处1/3：定义一个变量，记录当前任务列表。规范写法是在__init__中定义我为代码信中放在这里
        try:
            self.task_handler_list
        except:
            self.task_handler_list = []
        # 控制未完成任务数添加代码处2/3：提交任务时把任务句柄记录到上边定义的列表中
        task_handler = self.thread_pool.submit(self.do_task, para)
        self.task_handler_list.append(task_handler)
        # 控制未完成任务数添加代码处3/3：当未完成任务数不多于线程的2倍时才允许此任务返回
        while True:
            # 我们可能听说过使用as_completed()可以获取执行完成的任务列表，但实际发现as_completed是阻塞的他要等待任务响应他的询问
            # 所以并不推荐使用以下形式来获取未执行完成的任务列表
            # task_handler_list = list(set(task_handler_list) - set(concurrent.futures.as_completed(task_handler_list)))
            # 将已完成的任务移出列表
            for task_handler_tmp in self.task_handler_list:
                if task_handler_tmp.done():
                    self.task_handler_list.remove(task_handler_tmp)
            # 如果未完成的任务已多于线程数的两倍那么先停一下，先不要再增加任务，因为几万个ip一把放到内存中是个很大的消耗
            if len(self.task_handler_list) > 2 * 2:
                # print("unfinished task is more than double thread_count, will be wait a seconds.")
                # 睡眠多久看自己需要，我这设2秒
                time.sleep(2)
            else:
                return True

    def do_task(self, para):
        thread_name = threading.current_thread().name
        # 线程池+线程同步改造添加代码处4/5： 获取锁
        self.threadLock.acquire()

        para_name = para['para_name']

        print(f"this is thread : {thread_name}")
        print(f"downloading is : {para_name}")

        # 多线程下载视频
        self.download_viedo_service(para['file_path'], para['url'])

        # 线程池+线程同步改造添加代码处5/5： 释放锁
        self.threadLock.release()
        time.sleep(1)
        pass

    def download_viedo_service(self, file_path, url):
        
        try:
            
            # 代理浏览器请求头
            headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36"}
            pre_content_length = 0

            # 循环接收视频数据
            while True:# 若文件已经存在，则断点续传，设置接收来需接收数据的位置    
                if os.path.exists(file_path):
                    headers['Range'] = 'bytes=%d-' % os.path.getsize(file_path)
                res = requests.get(url, stream=True, headers=headers)
                content_length = int(res.headers['content-length'])
                # 若当前报文长度小于前次报文长度，或者已接收文件等于当前报文长度，则可以认为视频接收完成
                if content_length < pre_content_length or (os.path.exists(file_path) and os.path.getsize(file_path) >= content_length):
                    break
                pre_content_length = content_length
                # 写入收到的视频数据
                with open(file_path, 'ab') as file:
                    file.write(res.content)
                    file.flush()
                    print('receive data，file size : %d   total size:%d' % (os.path.getsize(file_path), content_length))
        except Exception as e:
            dic = {'url':url, 'file_path':file_path}
            print("下载失败:", dic)
            print('错误信息：', e)

def specifying_download(folder_path, chapters, user_cps=None):

    local_path = os.path.dirname(__file__)
    folder_path = os.path.join(local_path, folder_path)

    if not os.path.exists(folder_path):
        os.mkdir(folder_path)

    if user_cps is None:
        user_cps = range(len(chapters))

    for i in user_cps:
        subchapter_point_name = chapters[i]['chapter']['point_name']
        print(subchapter_point_name)
        subchapter_points = chapters[i]['points']
        
        # 创建章节文件夹
        chapter_path = os.path.join(folder_path, subchapter_point_name)
        if not os.path.exists(chapter_path):
            os.mkdir(chapter_path)

        # 遍历章节视频
        for subchapter in subchapter_points:
            file_name = subchapter['point_name'] + '.MP4'
            video_url = subchapter['video_url']

            file_path = os.path.join(chapter_path, file_name)

            # print('准备下载{0}, 下载地址：{1}'.format(file_path, video_url))

            # 下载视频
            #TODO：　多线程下载
            #download_viedo_service(file_path, video_url)
            para = {'para_name': file_name, 'file_path': file_path, 'url': video_url}
            time.sleep(.2)
            _threadpool.call_do_task(para)

def analysis_download(json_content):

    # 解析字符串
    preview = json_content['preview']
    chapters = json_content['chapters']


    print('++++++ 简易下载器 +++++++++')
    previewName = preview['previewName']
    print('[{0}] 一共有{1}章'.format(previewName, len(chapters)))
    print('全部下载按下任意键, 选择章节下载输入 0 ')
    menu = input()

    if menu == '0':
        cpstr = ''
        for i in range(len(chapters)):
            cpstr += ' {0} :{1} '.format(i, chapters[i]['chapter']['point_name'])

        print('请选择您要下载的章节, 例如 0,1,2,3 多个章节以逗号分割!')
        print(cpstr)
        cpstr = input()
        print('准备下载一下章节： ' , cpstr)
        cpstrs = cpstr.replace('，',',').split(',')
        print(cpstrs[1])
        # 转换为整数数组
        cpstrs = list(map(int, cpstrs))
        specifying_download(previewName, chapters, cpstrs)
    else:
        specifying_download(previewName, chapters)


def subject_title_name(url, cookie):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36",
        "Cookie": cookie,
        "Host": "stu.ityxb.com",
        "Connection": "keep-alive"
    }
    res = requests.get(url, stream=True, headers=headers)
    str_content = res.content
    json_content = json.loads(str_content)
    
    state =  str(json_content['success']).lower()

    if state == 'true':

        analysis_download(json_content['resultObject'])
    else:
        print('响应信息返回错误(如果是needLogin请检查你的cookie是否为最新): {0}'.format(json_content['resultObject']))

if __name__ == '__main__':
    
    max_thread = 30
    _threadpool = ThreadPoolMan(max_thread)

    # 拿到自己的账号COOKIE
    cookie = ''
    # 输入你要下载的课程ID
    subject_id = ''

    if cookie == '' or subject_id == '':
        print('请输入你的Cookie，可以在浏览器打开网站按 F12 查看：')
        cookie = input()

        print('请输入你要下载的课程ID，详细教程在  ：')
        subject_id = input()

    preview_info_url = 'http://stu.ityxb.com/back/bxg/preview/info?previewId=' + subject_id

    subject_title_name(preview_info_url, cookie)

    print('DONE!!!!!!!!!!!!!!!!!!!!! 程序运行完毕辣 !!!!!!!!!!!')
    # url = 'https://new-bxgstorge.boxuegu.com/bxg/textbook/093/afterClassVideo/093001002.mp4'
    #file_path ='C:/Users/MISAKIGA/Desktop/学习视频/'
    #download_viedo_service(file_path, url)