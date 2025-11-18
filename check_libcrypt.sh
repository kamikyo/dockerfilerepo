#!/bin/sh
# 检测 Docker 镜像中 libcrypt.so.1 的脚本
# 使用方法: ./check_libcrypt.sh <镜像名称>:<版本>
# 示例: ./check_libcrypt.sh registry.cn-chengdu.aliyuncs.com/kyoscontainers/net_images:3.22

# 检查参数
if [ -z "$1" ]; then
  echo "错误: 请提供镜像名称和版本作为参数"
  echo "使用方法: $0 <镜像名称>:<版本>"
  echo "示例: $0 registry.cn-chengdu.aliyuncs.com/kyoscontainers/net_images:3.22"
  exit 1
fi

IMAGE_NAME="$1"
echo "检测镜像: $IMAGE_NAME"
echo ""

echo "=== 方法1：搜索所有 libcrypt.so 文件 ==="
docker run --rm "$IMAGE_NAME" find /usr /lib -name "libcrypt.so*" 2>/dev/null

echo ""
echo "=== 方法2：检查常见位置并输出完整路径 ==="
docker run --rm "$IMAGE_NAME" sh -c '
  if [ -f /lib/libcrypt.so.1 ]; then
    echo "✓ 找到: /lib/libcrypt.so.1"
    ls -lh /lib/libcrypt.so.1
  else
    echo "✗ /lib/libcrypt.so.1 不存在"
  fi
  
  echo ""
  if [ -f /usr/lib/libcrypt.so.1 ]; then
    echo "✓ 找到: /usr/lib/libcrypt.so.1"
    ls -lh /usr/lib/libcrypt.so.1
  else
    echo "✗ /usr/lib/libcrypt.so.1 不存在"
  fi
  
  echo ""
  if [ -f /usr/glibc-compat/lib/libcrypt.so.1 ]; then
    echo "✓ 找到: /usr/glibc-compat/lib/libcrypt.so.1"
    ls -lh /usr/glibc-compat/lib/libcrypt.so.1
  else
    echo "✗ /usr/glibc-compat/lib/libcrypt.so.1 不存在"
  fi
'

echo ""
echo "=== 方法3：检查 gcompat 和 libc6-compat 是否已安装 ==="
docker run --rm "$IMAGE_NAME" sh -c '
  echo "检查已安装的包:"
  apk list --installed | grep -E "(gcompat|libc6-compat)" || echo "  ✗ 未找到相关包"
'

echo ""
echo "=== 方法4：使用 ldd 检查 iclit09b.so 的依赖（如果文件存在）==="
docker run --rm -v /home/demo:/app/site "$IMAGE_NAME" sh -c '
  if [ -f /app/site/gbase/lib/iclit09b.so ]; then
    echo "检查 iclit09b.so 的依赖:"
    ldd /app/site/gbase/lib/iclit09b.so 2>&1 | grep -E "(libcrypt|not found)" || echo "  未找到 libcrypt 相关依赖"
  else
    echo "  ✗ /app/site/gbase/lib/iclit09b.so 不存在"
  fi
'

echo ""
echo "=== 方法5：检查 LD_LIBRARY_PATH 和系统库路径 ==="
docker run --rm "$IMAGE_NAME" sh -c '
  echo "系统库搜索路径:"
  echo "  /lib: $(ls -d /lib 2>/dev/null && echo "存在" || echo "不存在")"
  echo "  /usr/lib: $(ls -d /usr/lib 2>/dev/null && echo "存在" || echo "不存在")"
  echo ""
  echo "检查 /lib 中的库:"
  ls -la /lib/*.so* 2>/dev/null | grep -E "(crypt|gcompat)" | head -10 || echo "  未找到相关库"
'

echo ""
echo "=== 总结：libcrypt.so.1 的完整路径 ==="
docker run --rm "$IMAGE_NAME" sh -c '
  LIB_PATH=$(find /usr /lib -name "libcrypt.so.1" 2>/dev/null | head -1)
  if [ -n "$LIB_PATH" ]; then
    echo "✓ libcrypt.so.1 完整路径: $LIB_PATH"
    echo "  文件详情:"
    ls -lh "$LIB_PATH"
    echo ""
    echo "  如果是符号链接，指向:"
    readlink -f "$LIB_PATH" 2>/dev/null || echo "    (不是符号链接或无法解析)"
  else
    echo "✗ 未找到 libcrypt.so.1"
  fi
'

